# fir.S 
# assembly language of Finite Impulse Response (FIR)

// a0: base address of x
// a1: base address of c
// a2: base address of y, later used as pointer to y[j] in j loop
// a3: n
// a4: m

// t0: &y[n-m] to check termination of j loop
// t1: &c[m] to check termination of i loop
// t2: &x[j+m-1]
// t3: sum
// t4: pointer to c[i] in i loop
// t5: pointer to x[j-i+(m-1)] 
// t6: value of c[i]
// a5: value of x[j-1+(m-1)]

.global fir

fir:
// n is the length of x, m is the length of c
// y[i] = c[0]*x[i] + c[1]*x[i+1] + ... + c[m-1]*x[i+m-1]
// inputs in Q1.31 format
void fir(int x[], int c[], int y[], int n, int m) {
    int i, j;
    for (j=0; j<n-m+1; j++) {
    800001d0:	40e68ebb          	subw	t4,a3,a4
    800001d4:	040ecd63          	bltz	t4,8000022e <fir+0x5e>
    800001d8:	fff7079b          	addiw	a5,a4,-1
    800001dc:	078a                	slli	a5,a5,0x2
    800001de:	00271893          	slli	a7,a4,0x2
    800001e2:	2e85                	addiw	t4,t4,1
    800001e4:	00f50333          	add	t1,a0,a5
    800001e8:	98ae                	add	a7,a7,a1
    800001ea:	4e01                	li	t3,0
        y[j] = 0;
    800001ec:	00062023          	sw	zero,0(a2)
        for (i=0; i<m; i++) 
    800001f0:	00e04f63          	bgtz	a4,8000020e <fir+0x3e>
    for (j=0; j<n-m+1; j++) {
    800001f4:	2e05                	addiw	t3,t3,1
    800001f6:	0611                	addi	a2,a2,4
    800001f8:	0311                	addi	t1,t1,4
    800001fa:	ffde19e3          	bne	t3,t4,800001ec <fir+0x1c>
    800001fe:	8082                	ret
    80000200:	2e05                	addiw	t3,t3,1
    80000202:	0611                	addi	a2,a2,4
    80000204:	0311                	addi	t1,t1,4
    80000206:	03de0463          	beq	t3,t4,8000022e <fir+0x5e>
        y[j] = 0;
    8000020a:	00062023          	sw	zero,0(a2)
    for (j=0; j<n-m+1; j++) {
    8000020e:	851a                	mv	a0,t1
    80000210:	872e                	mv	a4,a1
    80000212:	4681                	li	a3,0
  long res = (long)a * (long)b;
    80000214:	431c                	lw	a5,0(a4)
    80000216:	00052803          	lw	a6,0(a0)
        for (i=0; i<m; i++) 
    8000021a:	0711                	addi	a4,a4,4
    8000021c:	1571                	addi	a0,a0,-4
  long res = (long)a * (long)b;
    8000021e:	030787b3          	mul	a5,a5,a6
    int result = res >> 31; // shift right to get the 32-bit result; 
    80000222:	87fd                	srai	a5,a5,0x1f
  return a+b;
    80000224:	9ebd                	addw	a3,a3,a5
            y[j] = add_q31(y[j], mul_q31(c[i], x[j-i+(m-1)]));
    80000226:	c214                	sw	a3,0(a2)
        for (i=0; i<m; i++) 
    80000228:	fee896e3          	bne	a7,a4,80000214 <fir+0x44>
    8000022c:	bfd1                	j	80000200 <fir+0x30>
    }
}
    8000022e:	8082                	ret



donej:
    ret                 # all done; return	
