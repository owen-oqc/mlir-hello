; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; In PR41658, argpromotion put an inalloca in a position that per the
; calling convention is passed in a register. This test verifies that
; we don't do that anymore. It also verifies that the combination of
; globalopt and argpromotion is able to optimize the call safely.
;
; RUN: opt -attributor -enable-new-pm=0 -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=2 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=2 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -enable-new-pm=0 -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

target datalayout = "e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32"
target triple = "i386-pc-windows-msvc19.11.0"

%struct.a = type { i8 }

define internal x86_thiscallcc void @internalfun(%struct.a* %this, <{ %struct.a }>* inalloca(<{ %struct.a }>)) {
; CHECK-LABEL: define {{[^@]+}}@internalfun
; CHECK-SAME: (%struct.a* noalias nocapture nofree readnone [[THIS:%.*]], <{ [[STRUCT_A:%.*]] }>* noundef nonnull inalloca(<{ [[STRUCT_A]] }>) align 4 dereferenceable(1) [[TMP0:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = getelementptr inbounds <{ [[STRUCT_A]] }>, <{ [[STRUCT_A]] }>* [[TMP0]], i32 0, i32 0
; CHECK-NEXT:    [[ARGMEM:%.*]] = alloca inalloca <{ [[STRUCT_A]] }>, align 4
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds <{ [[STRUCT_A]] }>, <{ [[STRUCT_A]] }>* [[ARGMEM]], i32 0, i32 0
; CHECK-NEXT:    [[CALL:%.*]] = call x86_thiscallcc %struct.a* @copy_ctor(%struct.a* noundef nonnull align 4 dereferenceable(1) [[TMP1]], %struct.a* noundef nonnull align 4 dereferenceable(1) [[A]])
; CHECK-NEXT:    call void @ext(<{ [[STRUCT_A]] }>* noundef nonnull inalloca(<{ [[STRUCT_A]] }>) align 4 dereferenceable(1) [[ARGMEM]])
; CHECK-NEXT:    ret void
;
entry:
  %a = getelementptr inbounds <{ %struct.a }>, <{ %struct.a }>* %0, i32 0, i32 0
  %argmem = alloca inalloca <{ %struct.a }>, align 4
  %1 = getelementptr inbounds <{ %struct.a }>, <{ %struct.a }>* %argmem, i32 0, i32 0
  %call = call x86_thiscallcc %struct.a* @copy_ctor(%struct.a* %1, %struct.a* dereferenceable(1) %a)
  call void @ext(<{ %struct.a }>* inalloca(<{ %struct.a }>) %argmem)
  ret void
}

; This is here to ensure @internalfun is live.
define void @exportedfun(%struct.a* %a) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@exportedfun
; IS__TUNIT____-SAME: (%struct.a* nocapture nofree readnone [[A:%.*]]) {
; IS__TUNIT____-NEXT:    [[INALLOCA_SAVE:%.*]] = tail call i8* @llvm.stacksave() #[[ATTR1:[0-9]+]]
; IS__TUNIT____-NEXT:    [[ARGMEM:%.*]] = alloca inalloca <{ [[STRUCT_A:%.*]] }>, align 4
; IS__TUNIT____-NEXT:    call x86_thiscallcc void @internalfun(%struct.a* noalias nocapture nofree readnone undef, <{ [[STRUCT_A]] }>* noundef nonnull inalloca(<{ [[STRUCT_A]] }>) align 4 dereferenceable(1) [[ARGMEM]])
; IS__TUNIT____-NEXT:    call void @llvm.stackrestore(i8* nofree [[INALLOCA_SAVE]])
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@exportedfun
; IS__CGSCC____-SAME: (%struct.a* nocapture nofree readnone [[A:%.*]]) {
; IS__CGSCC____-NEXT:    [[INALLOCA_SAVE:%.*]] = tail call i8* @llvm.stacksave() #[[ATTR1:[0-9]+]]
; IS__CGSCC____-NEXT:    [[ARGMEM:%.*]] = alloca inalloca <{ [[STRUCT_A:%.*]] }>, align 4
; IS__CGSCC____-NEXT:    call x86_thiscallcc void @internalfun(%struct.a* noalias nocapture nofree readnone [[A]], <{ [[STRUCT_A]] }>* noundef nonnull inalloca(<{ [[STRUCT_A]] }>) align 4 dereferenceable(1) [[ARGMEM]])
; IS__CGSCC____-NEXT:    call void @llvm.stackrestore(i8* nofree [[INALLOCA_SAVE]])
; IS__CGSCC____-NEXT:    ret void
;
  %inalloca.save = tail call i8* @llvm.stacksave()
  %argmem = alloca inalloca <{ %struct.a }>, align 4
  call x86_thiscallcc void @internalfun(%struct.a* %a, <{ %struct.a }>* inalloca(<{ %struct.a }>) %argmem)
  call void @llvm.stackrestore(i8* %inalloca.save)
  ret void
}

declare x86_thiscallcc %struct.a* @copy_ctor(%struct.a* returned, %struct.a* dereferenceable(1))
declare void @ext(<{ %struct.a }>* inalloca(<{ %struct.a }>))
declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)
;.
; CHECK: attributes #[[ATTR0:[0-9]+]] = { nocallback nofree nosync nounwind willreturn }
; CHECK: attributes #[[ATTR1:[0-9]+]] = { willreturn }
;.