Create Procedure ATF010_##
 (
   @IN_DEPA1    float, 
   @IN_DEPA2    float, 
   @IN_DEPA3    float, 
   @IN_DEPA4    float, 
   @IN_DEPA5    float, 
   @IN_NRODIAS  integer,
   @IN_DATAACEL Char( 08 ),
   @IN_RECNO    integer,
   @OUT_DEP1    float OutPut,
   @OUT_DEP2    float OutPut,
   @OUT_DEP3    float OutPut,
   @OUT_DEP4    float OutPut,
   @OUT_DEP5    float OutPut
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo de Depreciação aCELERADA </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_DEPA1     - depreciacao do mes na moeda 1
                           @IN_DEPA2     - depreciacao do mes na moeda 2
                           @IN_DEPA3     - depreciacao do mes na moeda 3
                           @IN_DEPA4     - depreciacao do mes na moeda 4
                           @IN_DEPA5     - depreciacao do mes na moeda 5
                           @IN_NRODIAS   - nro de dias no mes a depreciar
                           @IN_RECNO     - RECNO  do registro
                           @IN_DATAACEL  - Data em q foi calculada a Depr Acelerada
    Saida           - <o>  @OUT_DEP1     - Valor da depreciacao na moeda 1 - valor da depreciacao acelerada na moeda1
                           @OUT_DEP2     - Valor da depreciacao na moeda 2 - valor da depreciacao acelerada na moeda2
                           @OUT_DEP3     - Valor da depreciacao na moeda 3 - valor da depreciacao acelerada na moeda3
                           @OUT_DEP4     - Valor da depreciacao na moeda 4 - valor da depreciacao acelerada na moeda4
                           @OUT_DEP5     - Valor da depreciacao na moeda 5 - valor da depreciacao acelerada na moeda5  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :          15/05/2007

Exemplo:   Ativo -> Valor do Ativo     - 1000,00
                    Taxa Dep Anual     - 100 
                    Taxa de Aceleracao - 1,5   -->  1   - 1 turno  de 8hs
                                                    1,5 - 2 turnos de 8hs
                                                    2,0 - 3 turnos de 8hs.
         
                 Acelerada 10                              10              Bx              11              Calc Depr
   dia ->  1------------------------------10--------------------------------20--------------------------------31
           |                              |                                  |                                 |
           |  26,88 * 1,5 = 40,32         |          26,88                   |                 29,57           |
            ------------------------------ --------------------------------------------------------------------
   Vls das deprecs:
   1 - Depreciacao mensal SEM Aceleracao e SEM bx  = ( 1000 * 100 / 1200 ) = 83,33
   2 - Depreciacao Mensal SEM Aceleracao COM bx no dia 20  = ( 83,33 /31 * 20 ) = 53,76
   3 - Depreciacao Mensal COM Aceleracao SEM bx no dia 20  = (( 83,33 /31 * 21 ) + 40,32 ) = 96,77
   3 - Depreciacao Mensal COM Aceleracao COM bx no dia 20  = (( 83,33 /31 * 10 ) + 40,32 ) = 67,20
-------------------------------------------------------------------------------------- */
Declare @nDiferenca  Float
Declare @nN3_VORIG1  float
Declare @nN3_VORIG2  float
Declare @nN3_VORIG3  float
Declare @nN3_VORIG4  float
Declare @nN3_VORIG5  float
Declare @nN3_VRDMES1 float 
Declare @nN3_VRDMES2 float 
Declare @nN3_VRDMES3 float 
Declare @nN3_VRDMES4 float 
Declare @nN3_VRDMES5 float 
Declare @nN3_AMPLIA1 float
Declare @nN3_AMPLIA2 float
Declare @nN3_AMPLIA3 float
Declare @nN3_AMPLIA4 float
Declare @nN3_AMPLIA5 float
Declare @nN3_VRDACM1 float
Declare @nN3_VRDACM2 float
Declare @nN3_VRDACM3 float
Declare @nN3_VRDACM4 float
Declare @nN3_VRDACM5 float
Declare @nN3_VRCACM1 float
Declare @nN3_VRCDA1  float
Declare @nValDepr1   float
Declare @nValDepr2   float
Declare @nValDepr3   float
Declare @nValDepr4   float
Declare @nValDepr5   float
Declare @iNroDiasA   integer  
Declare @nTaxaDepr   float

begin
   select @nDiferenca = 0
   select @nValDepr1 = @IN_DEPA1
   select @nValDepr2 = @IN_DEPA2
   select @nValDepr3 = @IN_DEPA3
   select @nValDepr4 = @IN_DEPA4
   select @nValDepr5 = @IN_DEPA5
   select @iNroDiasA  = convert(  integer, Substring( @IN_DATAACEL, 7,2 ))
   select @nTaxaDepr  = (@IN_NRODIAS-@iNroDiasA)
   select @nTaxaDepr  = @nTaxaDepr/@IN_NRODIAS
   
   Select @nN3_VORIG1  = N3_VORIG1,  @nN3_VORIG2  = N3_VORIG2,  @nN3_VORIG3  = N3_VORIG3,  @nN3_VORIG4  = N3_VORIG4,  @nN3_VORIG5  = N3_VORIG5,
          @nN3_VRDMES1 = N3_VRDMES1, @nN3_VRDMES2 = N3_VRDMES2, @nN3_VRDMES3 = N3_VRDMES3, @nN3_VRDMES4 = N3_VRDMES4, @nN3_VRDMES5 = N3_VRDMES5,
          @nN3_AMPLIA1 = N3_AMPLIA1, @nN3_AMPLIA2 = N3_AMPLIA2, @nN3_AMPLIA3 = N3_AMPLIA3, @nN3_AMPLIA4 = N3_AMPLIA4, @nN3_AMPLIA5 = N3_AMPLIA5,
          @nN3_VRDACM1 = N3_VRDACM1, @nN3_VRDACM2 = N3_VRDACM2, @nN3_VRDACM3 = N3_VRDACM3, @nN3_VRDACM4 = N3_VRDACM4, @nN3_VRDACM5 = N3_VRDACM5,
          @nN3_VRCACM1 = N3_VRCACM1, @nN3_VRCDA1  = N3_VRCDA1
     From SN3###
    Where R_E_C_N_O_ = @IN_RECNO
   
   If Abs(@nN3_VRDACM1 + @nN3_VRCDA1) < Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) begin
      Select @nValDepr1  = @nValDepr1 * @nTaxaDepr
      Select @nValDepr1  = @nValDepr1 + @nN3_VRDMES1
      Select @nDiferenca = Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) - (@nValDepr1 + Abs(@nN3_VRDACM1 + @nN3_VRCDA1))
      If ( @nDiferenca ) <= 0 begin
         Select @nValDepr1  = Abs( @nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1)- Abs(@nN3_VRDACM1 + @nN3_VRCDA1)
      End
   End
   If Abs(@nN3_VRDACM2 ) < Abs( @nN3_VORIG2 + @nN3_AMPLIA2 ) begin
      Select @nValDepr2  = @nValDepr2 * @nTaxaDepr
      Select @nValDepr2  = @nValDepr2 + @nN3_VRDMES2
      Select @nDiferenca = Abs(@nN3_VORIG2 + @nN3_AMPLIA2) - (@nValDepr2 + Abs(@nN3_VRDACM2))
      If ( @nDiferenca ) <= 0 begin
         Select @nValDepr2  = Abs( @nN3_VORIG2 + @nN3_AMPLIA2)- Abs(@nN3_VRDACM2)
      end
   End
   If Abs(@nN3_VRDACM3 ) < Abs( @nN3_VORIG3 + @nN3_AMPLIA3 ) begin
      Select @nValDepr3  = @nValDepr3 * @nTaxaDepr
      Select @nValDepr3  = @nValDepr3 + @nN3_VRDMES3
      Select @nDiferenca = Abs(@nN3_VORIG3 + @nN3_AMPLIA3) - (@nValDepr3 + Abs(@nN3_VRDACM3))
      If ( @nDiferenca ) <= 0 begin
         Select @nValDepr3  = Abs( @nN3_VORIG3 + @nN3_AMPLIA3)- Abs(@nN3_VRDACM3)
      end
   End
   If Abs(@nN3_VRDACM4 ) < Abs( @nN3_VORIG4 + @nN3_AMPLIA4 ) begin
      Select @nValDepr4  = @nValDepr4 * @nTaxaDepr
      Select @nValDepr4  = @nValDepr4 + @nN3_VRDMES4
      Select @nDiferenca = Abs(@nN3_VORIG4 + @nN3_AMPLIA4) - (@nValDepr4 + Abs(@nN3_VRDACM4))
      If ( @nDiferenca ) <= 0 begin
         Select @nValDepr4  = Abs( @nN3_VORIG4 + @nN3_AMPLIA4)- Abs(@nN3_VRDACM4)
      end
   End
   If Abs(@nN3_VRDACM5 ) < Abs( @nN3_VORIG5 + @nN3_AMPLIA5 ) begin
      Select @nValDepr5  = @nValDepr5 * @nTaxaDepr
      Select @nValDepr5  = @nValDepr5 + @nN3_VRDMES5
      Select @nDiferenca = Abs(@nN3_VORIG5 + @nN3_AMPLIA5) - (@nValDepr5 + Abs(@nN3_VRDACM5))
      If ( @nDiferenca ) <= 0 begin
         Select @nValDepr5  = Abs( @nN3_VORIG5 + @nN3_AMPLIA5)- Abs(@nN3_VRDACM5)
      end
   End
   
   Select @OUT_DEP1 = @nValDepr1
   Select @OUT_DEP2 = @nValDepr2
   Select @OUT_DEP3 = @nValDepr3
   Select @OUT_DEP4 = @nValDepr4
   Select @OUT_DEP5 = @nValDepr5
   
end
