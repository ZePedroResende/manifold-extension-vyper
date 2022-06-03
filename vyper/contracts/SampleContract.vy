# @version >=0.3.3
num2: uint256
MAX_UINT: constant(uint256) = MAX_UINT256

@external
def func1(num: uint256):
  self.num2 = num
  for i in range(MAX_UINT):
    if i == num :
      break
    self.num2-=1

  assert self.num2 == 0

@external
def func2(num: uint256):
  self.num2 = num
  for i in range(MAX_UINT):
    if i == num :
      break
    self.num2-=1

  assert self.num2 == 0
