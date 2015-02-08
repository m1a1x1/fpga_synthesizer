import math
#REQ_FREQ     = 480 # Hz
#SAMPLE_FREQ  = 48000 # Hz
#SAMPLES_CNT  = 100 

#SAMPLE_WIDTH = 16

#MASK = pow( 2, SAMPLE_WIDTH ) - 1
#MAX_VALUE = pow( 2, SAMPLE_WIDTH - 1 ) - 1

def simp_sin(  REQ_FREQ, SAMPLE_FREQ, SAMPLES_CNT, SAMPLE_WIDTH ): 

  all_vals = list( )
  MASK = pow( 2, SAMPLE_WIDTH ) - 1
  MAX_VALUE = pow( 2, SAMPLE_WIDTH - 1 ) - 1
  for i in xrange( SAMPLES_CNT ):
    val = int( math.floor( math.sin( 2 * math.pi * REQ_FREQ * ( ( i * 1.0 ) / SAMPLE_FREQ ) ) * MAX_VALUE ) ) & MASK
    if( i == SAMPLES_CNT - 1):
      all_vals.append( val + 2**16 )
    else:
      all_vals.append( val )
 
  return ( all_vals )

def simp_puls_0( SAMPLES_CNT, SAMPLE_WIDTH ):
  all_vals = list( )
  MAX_VALUE = pow( 2, SAMPLE_WIDTH - 1 ) - 1
  for i in range( SAMPLES_CNT/2 ):
    all_vals.append( MAX_VALUE )
  for i in range( SAMPLES_CNT/2):
    if( i == SAMPLES_CNT/2 - 1 ):
      all_vals.append( 2**16 )
    else:
      all_vals.append( 0 )
  return ( all_vals )

def simp_puls_bi( SAMPLES_CNT, SAMPLE_WIDTH ):
  all_vals = list( )
  MAX_VALUE = pow( 2, SAMPLE_WIDTH - 1 ) - 1
  for i in range( SAMPLES_CNT/2 ):
    all_vals.append( MAX_VALUE )
  for i in range( SAMPLES_CNT/2 ):
    if( i == SAMPLES_CNT/2 - 1 ):
      all_vals.append( 2**16 + MAX_VALUE + 2**15 )
    else:
      all_vals.append( MAX_VALUE + 2**15 )
  return ( all_vals )

def print_sin( simp ):
  new_s = simp
  new_s[-1] = simp[-1]-2**16
  cnt = 0
  for i in new_s:
    print ( cnt, i )
    cnt += 1

def zeros( SAMPLES_CNT ):
  all_vals = list( )
  for i in range( SAMPLES_CNT/2 ):
    if( i == SAMPLES_CNT/2 - 1 ):
      all_vals.append( 2**16 )
    else:
      all_vals.append( 0 )
  return( all_vals )   



simp1 =  simp_sin( 523.25, 48000, 92, 16 )
#print_sin( simp1 )

simp2 = simp_sin( 587.33, 48000, 82, 16 )
#simp_sin( 587.33, 48000, 82, 16 )
#print_sin( simp2 )

simp3 = simp_sin( 659.26, 48000, 73, 16 )
#print_sin( simp3 )

simp4 = simp_sin( 698.46, 48000, 69, 16 )
#print_sin( simp4 )

simp5 = simp_sin( 783.99, 48000, 62, 16 )
#print_sin( simp5 )

simp6 = simp_sin( 880, 48000, 55, 16 )
#print_sin( simp6 )

simp7 = simp_sin( 987.77, 48000, 49, 16 )
#print_sin( simp7 )

simp8 =  simp_sin( 1046.5, 48000, 46, 16 )
#print_sin( simp8 )

all_simps = list( )
all_simps.append( simp1 )
all_simps.append( simp2 )
all_simps.append( simp3 )
all_simps.append( simp4 )
all_simps.append( simp5 )
all_simps.append( simp6 )
all_simps.append( simp7 )
all_simps.append( simp8 )


f = open( 'jingls.mif', "w" )
f.write("DEPTH=%d;\n" % 2**12 )
f.write("WIDTH=%d;\n" % 17    )
f.write("ADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n" )

for i in range(len(all_simps)):
  for j in range(len(all_simps[ i ])):
    adr = i << 9 | j
    f.write( "%s : %s;\n" % ( adr, hex(all_simps[i][j])[2:] ) )

f.write("END;")
