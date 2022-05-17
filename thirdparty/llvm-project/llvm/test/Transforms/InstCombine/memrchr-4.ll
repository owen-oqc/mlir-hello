; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s
;
; Verify that memrchr calls with a string consisting of all the same
; characters are folded.

declare i8* @memrchr(i8*, i32, i64)

@a11111 = constant [5 x i8] c"\01\01\01\01\01"
@a1110111 = constant [7 x i8] c"\01\01\01\00\01\01\01"


; Fold memrchr(a11111, C, 5) to *a11111 == C ? a11111 + 5 - 1 : null.

define i8* @fold_memrchr_a11111_c_5(i32 %C) {
; CHECK-LABEL: @fold_memrchr_a11111_c_5(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @memrchr(i8* noundef nonnull dereferenceable(5) getelementptr inbounds ([5 x i8], [5 x i8]* @a11111, i64 0, i64 0), i32 [[C:%.*]], i64 5)
; CHECK-NEXT:    ret i8* [[RET]]
;

  %ptr = getelementptr [5 x i8], [5 x i8]* @a11111, i64 0, i64 0
  %ret = call i8* @memrchr(i8* %ptr, i32 %C, i64 5)
  ret i8* %ret
}


; Fold memrchr(a1110111, C, 3) to a1110111[2] == C ? a1110111 + 2 : null.

define i8* @fold_memrchr_a1110111_c_3(i32 %C) {
; CHECK-LABEL: @fold_memrchr_a1110111_c_3(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @memrchr(i8* noundef nonnull dereferenceable(3) getelementptr inbounds ([7 x i8], [7 x i8]* @a1110111, i64 0, i64 0), i32 [[C:%.*]], i64 3)
; CHECK-NEXT:    ret i8* [[RET]]
;

  %ptr = getelementptr [7 x i8], [7 x i8]* @a1110111, i64 0, i64 0
  %ret = call i8* @memrchr(i8* %ptr, i32 %C, i64 3)
  ret i8* %ret
}


; Don't fold memrchr(a1110111, C, 4).

define i8* @call_memrchr_a1110111_c_4(i32 %C) {
; CHECK-LABEL: @call_memrchr_a1110111_c_4(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @memrchr(i8* noundef nonnull dereferenceable(4) getelementptr inbounds ([7 x i8], [7 x i8]* @a1110111, i64 0, i64 0), i32 [[C:%.*]], i64 4)
; CHECK-NEXT:    ret i8* [[RET]]
;

  %ptr = getelementptr [7 x i8], [7 x i8]* @a1110111, i64 0, i64 0
  %ret = call i8* @memrchr(i8* %ptr, i32 %C, i64 4)
  ret i8* %ret
}


; Don't fold memrchr(a1110111, C, 7).

define i8* @call_memrchr_a11111_c_7(i32 %C) {
; CHECK-LABEL: @call_memrchr_a11111_c_7(
; CHECK-NEXT:    [[RET:%.*]] = call i8* @memrchr(i8* noundef nonnull dereferenceable(7) getelementptr inbounds ([7 x i8], [7 x i8]* @a1110111, i64 0, i64 0), i32 [[C:%.*]], i64 7)
; CHECK-NEXT:    ret i8* [[RET]]
;

  %ptr = getelementptr [7 x i8], [7 x i8]* @a1110111, i64 0, i64 0
  %ret = call i8* @memrchr(i8* %ptr, i32 %C, i64 7)
  ret i8* %ret
}