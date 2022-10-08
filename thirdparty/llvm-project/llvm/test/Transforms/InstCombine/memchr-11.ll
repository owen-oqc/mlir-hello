; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s
;
; Verify that the result of memchr calls used in equality expressions
; with either the first argument or null are optimally folded.

declare i8* @memchr(i8*, i32, i64)


@a5 = constant [5 x i8] c"12345"

; Fold memchr(a5, c, 5) == a5 to *a5 == c.

define i1 @fold_memchr_a_c_5_eq_a(i32 %c) {
; CHECK-LABEL: @fold_memchr_a_c_5_eq_a(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i32 [[C:%.*]] to i8
; CHECK-NEXT:    [[CHAR0CMP:%.*]] = icmp eq i8 [[TMP1]], 49
; CHECK-NEXT:    ret i1 [[CHAR0CMP]]
;
  %p = getelementptr [5 x i8], [5 x i8]* @a5, i32 0, i32 0
  %q = call i8* @memchr(i8* %p, i32 %c, i64 5)
  %cmp = icmp eq i8* %q, %p
  ret i1 %cmp
}


; Fold memchr(a5, c, n) == a5 to n && *a5 == c.  Unlike the case when
; the first argument is an arbitrary, including potentially past-the-end,
; pointer, this is safe because a5 is dereferenceable.

define i1 @fold_memchr_a_c_n_eq_a(i32 %c, i64 %n) {
; CHECK-LABEL: @fold_memchr_a_c_n_eq_a(
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i32 [[C:%.*]] to i8
; CHECK-NEXT:    [[CHAR0CMP:%.*]] = icmp eq i8 [[TMP1]], 49
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i64 [[N:%.*]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = select i1 [[TMP2]], i1 [[CHAR0CMP]], i1 false
; CHECK-NEXT:    ret i1 [[TMP3]]
;
  %p = getelementptr [5 x i8], [5 x i8]* @a5, i32 0, i32 0
  %q = call i8* @memchr(i8* %p, i32 %c, i64 %n)
  %cmp = icmp eq i8* %q, %p
  ret i1 %cmp
}


; Do not fold memchr(a5 + i, c, n).

define i1 @call_memchr_api_c_n_eq_a(i64 %i, i32 %c, i64 %n) {
; CHECK-LABEL: @call_memchr_api_c_n_eq_a(
; CHECK-NEXT:    [[P:%.*]] = getelementptr [5 x i8], [5 x i8]* @a5, i64 0, i64 [[I:%.*]]
; CHECK-NEXT:    [[Q:%.*]] = call i8* @memchr(i8* [[P]], i32 [[C:%.*]], i64 [[N:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8* [[Q]], [[P]]
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %p = getelementptr [5 x i8], [5 x i8]* @a5, i64 0, i64 %i
  %q = call i8* @memchr(i8* %p, i32 %c, i64 %n)
  %cmp = icmp eq i8* %q, %p
  ret i1 %cmp
}


; Fold memchr(s, c, 15) == s to *s == c.

define i1 @fold_memchr_s_c_15_eq_s(i8* %s, i32 %c) {
; CHECK-LABEL: @fold_memchr_s_c_15_eq_s(
; CHECK-NEXT:    [[TMP1:%.*]] = load i8, i8* [[S:%.*]], align 1
; CHECK-NEXT:    [[TMP2:%.*]] = trunc i32 [[C:%.*]] to i8
; CHECK-NEXT:    [[CHAR0CMP:%.*]] = icmp eq i8 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret i1 [[CHAR0CMP]]
;
  %p = call i8* @memchr(i8* %s, i32 %c, i64 15)
  %cmp = icmp eq i8* %p, %s
  ret i1 %cmp
}


; Fold memchr(s, c, 17) != s to *s != c.

define i1 @fold_memchr_s_c_17_neq_s(i8* %s, i32 %c) {
; CHECK-LABEL: @fold_memchr_s_c_17_neq_s(
; CHECK-NEXT:    [[TMP1:%.*]] = load i8, i8* [[S:%.*]], align 1
; CHECK-NEXT:    [[TMP2:%.*]] = trunc i32 [[C:%.*]] to i8
; CHECK-NEXT:    [[CHAR0CMP:%.*]] = icmp ne i8 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret i1 [[CHAR0CMP]]
;
  %p = call i8* @memchr(i8* %s, i32 %c, i64 17)
  %cmp = icmp ne i8* %p, %s
  ret i1 %cmp
}


; Fold memchr(s, c, n) == s to *s == c for nonzero n.

define i1 @fold_memchr_s_c_nz_eq_s(i8* %s, i32 %c, i64 %n) {
; CHECK-LABEL: @fold_memchr_s_c_nz_eq_s(
; CHECK-NEXT:    [[TMP1:%.*]] = load i8, i8* [[S:%.*]], align 1
; CHECK-NEXT:    [[TMP2:%.*]] = trunc i32 [[C:%.*]] to i8
; CHECK-NEXT:    [[CHAR0CMP:%.*]] = icmp eq i8 [[TMP1]], [[TMP2]]
; CHECK-NEXT:    ret i1 [[CHAR0CMP]]
;
  %nz = or i64 %n, 1
  %p = call i8* @memchr(i8* %s, i32 %c, i64 %nz)
  %cmp = icmp eq i8* %p, %s
  ret i1 %cmp
}


; But do not fold memchr(s, c, n) as above if n might be zero.  This could
; be optimized to the equivalent of N && *S == C provided a short-circuiting
; AND, otherwise the load could read a byte just past the end of an array.

define i1 @call_memchr_s_c_n_eq_s(i8* %s, i32 %c, i64 %n) {
; CHECK-LABEL: @call_memchr_s_c_n_eq_s(
; CHECK-NEXT:    [[P:%.*]] = call i8* @memchr(i8* [[S:%.*]], i32 [[C:%.*]], i64 [[N:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8* [[P]], [[S]]
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %p = call i8* @memchr(i8* %s, i32 %c, i64 %n)
  %cmp = icmp eq i8* %p, %s
  ret i1 %cmp
}