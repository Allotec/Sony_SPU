package const is
	constant WIDTH : integer := 128;

  constant QUAD_WORDSIZE : integer := 128;
  constant QUAD_WORDS : integer := WIDTH / QUAD_WORDSIZE;

  constant DOUBLE_WORDSIZE : integer := 64;
  constant DOUBLE_WORDS : integer := WIDTH / DOUBLE_WORDSIZE;
	
  constant WORDSIZE : integer := 32;
  constant WORDS : integer := WIDTH / WORDSIZE;

  constant HALF_WORDSIZE : integer := 16;
	constant HALF_WORDS : integer := WIDTH / HALF_WORDSIZE;
	
  constant BYTE_SIZE : integer := 8;
  constant BYTES : integer := WIDTH / BYTE_SIZE;
end package;
