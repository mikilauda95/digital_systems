def mask1(n):
    """Return a bitmask of length n (suitable for masking against an
    int to coerce the size to a given length)
    """
    if n >= 0:
        return 2**n - 1
    else:
        return 0

def ror(n, rotations=1, width=8):
    """Return a given number of bitwise right rotations of an integer n,
    for a given bit field width.
    """
    rotations %= width * 8  #  width bytes give 8*bytes bits
    if rotations < 1:
        return n
    mask = mask1(8 * width)  # store the mask
    n &= mask
    return (n >> rotations) | ((n << (8 * width - rotations)) & mask)  # apply the mask to result


# Function to right
# rotate n by d bits
def rightRotate(n, rotations = 2, width = 32 ):

    # In n>>d, first d bits are 0.
    # To put last 3 bits of at
    # first, do bitwise or of n>>d
    # with n <<(INT_BITS - d)
    return (n >> rotations)|(n << (width - rotations)) & 0xFFFFFFFF

def Ch(x, y, z ):
    return (x & y) ^ (x & z)
def Maj (x, y, z ):
    return (x & y)^(x & z)^(y & z)
def sigma0_s(x):
    return ((rightRotate(x, rotations = 7, width = 32) ^
             rightRotate(x, rotations = 18, width = 32) ^
             x >> 3) %(1<<32))
def sigma1_s(x):
    return ((rightRotate(x, rotations = 17, width = 32) ^
             rightRotate(x, rotations = 19, width = 32) ^
             x >> 10)%(1<<32))
def sigma0_b(x):
    return ((rightRotate(x, rotations = 2, width = 32) ^
             rightRotate(x, rotations = 13, width = 32) ^
             rightRotate(x, rotations = 22, width = 32) ))
def sigma1_b(x):
    return ((rightRotate(x, rotations = 6, width = 32) ^
             rightRotate(x, rotations = 11, width = 32) ^
             rightRotate(x, rotations = 25, width = 32) ))

def M16_64_fun(W, i):
    return((sigma1_s(W[i-2]) + W[i-7] + sigma0_s(W[i-15]) + W[i-16])%(1<<32))




M = [ 0X61626380, 0X00000000, 0X00000000, 0X00000000, 0X00000000, 0X00000000, 0X00000000, 0X00000000,
     0X00000000, 0X00000000, 0X00000000, 0X00000000, 0X00000000, 0X00000000, 0X00000000, 0X00000018 ]


res = []
for i in range(64):
    if i < 16:
        res.append(M[i])
        # print("%08x"%M[i])
    else:
        res.append(M16_64_fun(res, i))
# for i in range(len(res)):
    # print(i)
    # print("%08x"%res[i])

# a = sigma0_b(s_M_in(0))


a = sigma0_b(M[-1])
print("%08x"%a,type(a))
a = sigma1_b(M[-1])
print("%08x"%a,type(a))
# a = sigma1_s(M[-1])
# print("%08x"%a,type(a))
a = M[0]
print("%08x"%a,type(a))
a = (rightRotate(M[0], rotations = 6, width = 32))
print("%08x"%a,type(a))

# a = (M[-1])
# print("%08x"%a,type(a))

# a = rightRotate(M[-1], 8, 32)
# print("%08x"%a,type(a))
