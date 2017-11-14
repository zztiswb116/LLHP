; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-macosx10.9 -verify-machineinstrs -mattr=cx16 | FileCheck %s

@var = global i128 0

; Due to the scheduling right after isel for cmpxchg and given the
; machine scheduler and copy coalescer do not mess up with physical
; register live-ranges, we end up with a useless copy.
define i128 @val_compare_and_swap(i128* %p, i128 %oldval, i128 %newval) {
; CHECK-LABEL: val_compare_and_swap:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rcx, %r9
; CHECK-NEXT:    movq %rsi, %rax
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    movq %r9, %rbx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %pair = cmpxchg i128* %p, i128 %oldval, i128 %newval acquire acquire
  %val = extractvalue { i128, i1 } %pair, 0
  ret i128 %val
}

define void @fetch_and_nand(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_nand:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB1_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    andq %r8, %rcx
; CHECK-NEXT:    movq %rax, %rbx
; CHECK-NEXT:    andq %rsi, %rbx
; CHECK-NEXT:    notq %rbx
; CHECK-NEXT:    notq %rcx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB1_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw nand i128* %p, i128 %bits release
  store i128 %val, i128* @var, align 16
  ret void
}

define void @fetch_and_or(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_or:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB2_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq %rax, %rbx
; CHECK-NEXT:    orq %rsi, %rbx
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    orq %r8, %rcx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB2_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw or i128* %p, i128 %bits seq_cst
  store i128 %val, i128* @var, align 16
  ret void
}

define void @fetch_and_add(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_add:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB3_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq %rax, %rbx
; CHECK-NEXT:    addq %rsi, %rbx
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    adcq %r8, %rcx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB3_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw add i128* %p, i128 %bits seq_cst
  store i128 %val, i128* @var, align 16
  ret void
}

define void @fetch_and_sub(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_sub:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB4_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    movq %rax, %rbx
; CHECK-NEXT:    subq %rsi, %rbx
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    sbbq %r8, %rcx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB4_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw sub i128* %p, i128 %bits seq_cst
  store i128 %val, i128* @var, align 16
  ret void
}

define void @fetch_and_min(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_min:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB5_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    cmpq %rax, %rsi
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    sbbq %rdx, %rcx
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    cmovgeq %rdx, %rcx
; CHECK-NEXT:    movq %rsi, %rbx
; CHECK-NEXT:    cmovgeq %rax, %rbx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB5_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw min i128* %p, i128 %bits seq_cst
  store i128 %val, i128* @var, align 16
  ret void
}

define void @fetch_and_max(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_max:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB6_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    cmpq %rsi, %rax
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    sbbq %r8, %rcx
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    cmovgeq %rdx, %rcx
; CHECK-NEXT:    movq %rsi, %rbx
; CHECK-NEXT:    cmovgeq %rax, %rbx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB6_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw max i128* %p, i128 %bits seq_cst
  store i128 %val, i128* @var, align 16
  ret void
}

define void @fetch_and_umin(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_umin:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB7_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    cmpq %rax, %rsi
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    sbbq %rdx, %rcx
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    cmovaeq %rdx, %rcx
; CHECK-NEXT:    movq %rsi, %rbx
; CHECK-NEXT:    cmovaeq %rax, %rbx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB7_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw umin i128* %p, i128 %bits seq_cst
  store i128 %val, i128* @var, align 16
  ret void
}

define void @fetch_and_umax(i128* %p, i128 %bits) {
; CHECK-LABEL: fetch_and_umax:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %r8
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB8_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    cmpq %rax, %rsi
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    sbbq %rdx, %rcx
; CHECK-NEXT:    movq %r8, %rcx
; CHECK-NEXT:    cmovbq %rdx, %rcx
; CHECK-NEXT:    movq %rsi, %rbx
; CHECK-NEXT:    cmovbq %rax, %rbx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB8_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    movq %rdx, _var+{{.*}}(%rip)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
  %val = atomicrmw umax i128* %p, i128 %bits seq_cst
  store i128 %val, i128* @var, align 16
  ret void
}

define i128 @atomic_load_seq_cst(i128* %p) {
; CHECK-LABEL: atomic_load_seq_cst:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    xorl %ebx, %ebx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
   %r = load atomic i128, i128* %p seq_cst, align 16
   ret i128 %r
}

define i128 @atomic_load_relaxed(i128* %p) {
; CHECK-LABEL: atomic_load_relaxed:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    xorl %ebx, %ebx
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
   %r = load atomic i128, i128* %p monotonic, align 16
   ret i128 %r
}

define void @atomic_store_seq_cst(i128* %p, i128 %in) {
; CHECK-LABEL: atomic_store_seq_cst:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    movq %rsi, %rbx
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB11_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB11_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
   store atomic i128 %in, i128* %p seq_cst, align 16
   ret void
}

define void @atomic_store_release(i128* %p, i128 %in) {
; CHECK-LABEL: atomic_store_release:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    movq %rsi, %rbx
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB12_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB12_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
   store atomic i128 %in, i128* %p release, align 16
   ret void
}

define void @atomic_store_relaxed(i128* %p, i128 %in) {
; CHECK-LABEL: atomic_store_relaxed:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    movq %rsi, %rbx
; CHECK-NEXT:    movq (%rdi), %rax
; CHECK-NEXT:    movq 8(%rdi), %rdx
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB13_1: ## %atomicrmw.start
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    lock cmpxchg16b (%rdi)
; CHECK-NEXT:    jne LBB13_1
; CHECK-NEXT:  ## BB#2: ## %atomicrmw.end
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    retq
   store atomic i128 %in, i128* %p unordered, align 16
   ret void
}