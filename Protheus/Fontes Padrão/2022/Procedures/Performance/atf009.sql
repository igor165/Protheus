Create Procedure ATF009_##(
   @IN_DATADEP    Char( 08 ),
   @IN_TAXCOR     float,
   @IN_TXDEP1     float,
   @IN_RECNO      Integer,
   @OUT_VALCOR    float OutPut,
   @OUT_VALCORDEP float OutPut,
   @OUT_VALCORDAC float OutPut,
   @OUT_VALDEPR1  float OutPut   
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  SOMENTE PARA O CHILE - Calculo de Depreciação  e Correcoes </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_DATADEP    - Data de Processamento
                           @IN_TAXCOR     - Taxa de Correcao a ser aplicada
                           @IN_TXDEP1     - Taxa de depreciacao mensal
                           @IN_RECNO      - recno do SN3  </ri>
    Saida           - <o>  @OUT_VALCOR    - Valor da correcao do bem
                           @OUT_VALCORDEP - valor da correcao da depreciacao
                           @OUT_VALCORDAC - Correcao
                           @OUT_VALDEPR1  - Valor da depreciacao  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     10/10/2006
   ------------------------------------------------------------------------------------*/
Declare @nN3_VORIG1  Decimal( 'N3_VORIG1' )
Declare @nN3_AMPLIA1 Decimal( 'N3_AMPLIA1' )
Declare @nN3_VRDACM1 Decimal( 'N3_VRDACM1' )
Declare @nN3_VRCACM1 Decimal( 'N3_VRCACM1' )
Declare @nN3_VRCDA1  Decimal( 'N3_VRCDA1' )
Declare @cN3_CCORREC Char( 'N3_CCORREC' )
Declare @cN3_CDESP   Char( 'N3_CDESP' )
Declare @nN3_VRCBAL1 Decimal( 'N3_VRCBAL1' )
Declare @nN3_VRCDB1  Decimal( 'N3_VRCDB1' )
Declare @cN3_DINDEPR Decimal( 'N3_DINDEPR' )
Declare @cN3_AQUISIC Decimal( 'N3_AQUISIC' )
Declare @nN3_CLNCOA  Decimal( 'N3_VORIG1' )
Declare @nN3_CLVRDEA Decimal( 'N3_VORIG1' )
Declare @nN3_CLCORDE Decimal( 'N3_VORIG1' )
Declare @nValCorDAC  Decimal( 'N3_VORIG1' )
Declare @nValCor     Decimal( 'N3_VORIG1' )
Declare @nValCorDep  Decimal( 'N3_VORIG1' )
Declare @iNroMeses   Integer
Declare @nMesdreact  Decimal( 'N3_VORIG1' )
Declare @nClncoa     Decimal( 'N3_VORIG1' )
Declare @nPedre      Decimal( 'N3_VORIG1' )
Declare @nMesDepAc   Integer
Declare @nValDepr1   Decimal( 'N3_VRDMES1' )
Declare @nDiferenca  Float
Declare @nN3_CLVRCOA Decimal( 'N3_VORIG1' )
Declare @nN3_VRCDM1  Decimal( 'N3_VORIG1' )

Begin
   select @nValCorDAC = 0
   select @nValCor    = 0
   select @nValCorDep = 0
   select @nValDepr1  = 0
   
   ##FIELDP01( 'SN3.N3_CLVRCOA;N3_CLVRDEA;N3_N3_CLCORDE' )   
   Select @nN3_VORIG1  = N3_VORIG1,  @nN3_AMPLIA1 = N3_AMPLIA1, @nN3_VRDACM1 = N3_VRDACM1, @nN3_VRCACM1 = N3_VRCACM1, @nN3_VRCDA1  = N3_VRCDA1,
          @cN3_CCORREC = N3_CCORREC, @cN3_CDESP   = N3_CDESP,   @nN3_VRCBAL1 = N3_VRCBAL1, @nN3_VRCDB1  = N3_VRCDB1,  @cN3_DINDEPR = N3_DINDEPR,
          @cN3_AQUISIC = N3_AQUISIC, @nN3_CLVRCOA = N3_CLVRCOA, @nN3_CLVRDEA = N3_CLVRDEA, @nN3_CLCORDE = N3_CLCORDE
     From SN3###
    Where R_E_C_N_O_ = @IN_RECNO
      
   If @IN_TAXCOR <> 0 begin
      select @iNroMeses = 0
      /* ------------------------------------------------------------------------------------
         Nao calcula as Correcoes do Bem e da Depreciacao no mes de Aquisicao
         ------------------------------------------------------------------------------------ */
      If SubString(@cN3_AQUISIC, 1,6 ) < SubString(@IN_DATADEP, 1, 6 )  begin
         If Substring(@IN_DATADEP, 1, 4) = SubString(@cN3_DINDEPR, 1, 4) begin
            select @iNroMeses = Convert( int, Substring(@IN_DATADEP, 5, 2))  - Convert( int, SubString(@cN3_DINDEPR, 5, 2) )
         end else begin
            select @iNroMeses = Convert( int, Substring( @IN_DATADEP, 5, 2 )) - 1
         end
         
         select @nValCor    = Round( ((@nN3_VORIG1 +  @nN3_CLVRCOA + @nN3_AMPLIA1) * @IN_TAXCOR), 0 ) - @nN3_VRCBAL1
         Select @nValCorDep = Round( ((@nN3_CLVRDEA + @nN3_CLCORDE) * @IN_TAXCOR), 0 ) - @nN3_VRCDB1
         
         If @iNroMeses >= 1 and ( SubString(@cN3_DINDEPR, 1, 4) < SubString(@IN_DATADEP, 1, 4) ) begin
            select @nValCorDAC = Round( ((@nN3_VORIG1 + @nN3_CLVRCOA + @nN3_AMPLIA1) * @iNroMeses * @IN_TAXCOR * @IN_TXDEP1), 0 )
         End
      End
   end
   
   If ( @IN_TXDEP1 <> 0 and (@cN3_DINDEPR <= @IN_DATADEP))  begin
      select @nMesdreact = 0
      select @nClncoa    = 0
      select @nPedre     = 0
      select @nMesDepAc  = 0
      select @nDiferenca = 0
      
      select @nPedre = Round( (1/@IN_TXDEP1 * 100 * 12),0 )
      If SubString( @cN3_DINDEPR, 1, 4 ) = SubString( @IN_DATADEP, 1, 4 ) begin
         Select @nMesdreact = Convert( int, SubString( @IN_DATADEP, 5, 2 ) ) - Convert( int, SubString( @cN3_DINDEPR, 5, 2) ) + 1
      end else begin
         Select @nMesdreact = Convert( int, SubString( @IN_DATADEP, 5, 2) )
      end 
      If @nMesdreact > (@nPedre - @nN3_CLNCOA ) begin
         select @nMesdreact = (@nPedre - @nN3_CLNCOA )
      end
      If @nN3_CLNCOA > @nPedre select @nClncoa = @nPedre
      else select @nClncoa = @nN3_CLNCOA
      
      If SubString( @cN3_DINDEPR, 1, 4 ) <> SubString( @IN_DATADEP, 1, 4 ) begin
         Select @nMesDepAc = ( 13 - Convert( int, SubString( @cN3_DINDEPR, 5, 2 )))
         Select @nMesDepAc = @nMesDepAc + ( 12 * ( SubString( @IN_DATADEP, 1, 4 ) - SubString( @cN3_DINDEPR, 1, 4 ) )) - 12
      End
      If SubString( @cN3_DINDEPR, 1, 4 ) = SubString( @IN_DATADEP, 1, 4 ) begin
         Select @nValDepr1 = ( (@nN3_VORIG1 + @nN3_AMPLIA1 + @nN3_CLVRCOA ) + ( @nValCor + @nN3_VRCACM1 ) - 
                                @nN3_CLVRDEA - ( @nValCorDep - @nN3_VRCDM1) ) / (( @nPedre - @nMesDepAc ) - @nClncoa )
      end else begin
         Select @nValDepr1 = ( (@nN3_VORIG1 + @nN3_AMPLIA1 + @nN3_VRCACM1 ) +  @nValCor - 
                             (( @nValCorDep - @nN3_VRCDM1) + @nN3_CLVRDEA + @nN3_VRCDM1 ))/ (( @nPedre - @nMesDepAc ) - @nClncoa )
      end
      Select @nValDepr1 =  Round( (( @nValDepr1 * @nMesdreact) - @nN3_VRCDA1 ), 0)
      Select @nDiferenca = Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) - ( @nValDepr1 + Abs( @nN3_VRDACM1 + @nN3_VRCDA1 ))
      if Round( @nDiferenca , 0 ) <= 0 begin
         select @nValDepr1 = Abs(@nN3_VORIG1 + @nN3_VRCACM1 + @nN3_AMPLIA1) - Abs( @nN3_VRDACM1 + @nN3_VRCDA1 )
         select @nValDepr1 = @nValDepr1 + Round(( @nValCor * @nMesdreact) / @nPedre, 0)
      end
   end
   ##ENDFIELDP01
   select @OUT_VALCOR    = @nValCor
   select @OUT_VALCORDEP = @nValCorDep
   select @OUT_VALCORDAC = @nValCorDAC
   select @OUT_VALDEPR1  = @nValDepr1
   
End
