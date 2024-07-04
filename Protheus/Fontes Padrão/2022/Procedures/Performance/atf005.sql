Create Procedure ATF005_##
 (
   @IN_FILIAL     Char( 'N3_FILIAL' ),
   @IN_CBASE      Char( 'N3_CBASE' ),
   @IN_ITEM       Char( 'N3_ITEM' ),
   @IN_TIPO       Char( 'N3_TIPO' ),
   @IN_BAIXA      Char( 'N3_BAIXA' ),
   @IN_SEQ        Char( 'N3_SEQ' ),
   @IN_N1TPNEG    VarChar( 250 ),
   @IN_N3TPNEG    VarChar( 250 ),
   @IN_MOEDAATF   Char( 02 ),
   @IN_LCALCULA   Char( 01 ),
   @IN_DATADEP    Char( 08 ),
   @IN_VCORRECAO  Float,
   @IN_LMESCHEIO  Char( 01 ),
   @IN_RECNO      integer,
   @OUT_DEPR1     Float OutPut,
   @OUT_DEPR2     Float OutPut,
   @OUT_DEPR3     Float OutPut,
   @OUT_DEPR4     Float OutPut,
   @OUT_DEPR5     Float OutPut,
   @OUT_COR       Float OutPut,
   @OUT_CORDEP    Float OutPut,
   @OUT_TXMEDIA   Float OutPut
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo de Depreciação de bem baixado </d>
    Funcao do Siga  -      Atfa050()
    Entrada         - <ri> @IN_FILIAL     - Filial corrente
                           @IN_CBASE      - Codigo do bem Char( 'N3_CBASE' ),
                           @IN_ITEM       Char( 'N3_ITEM' ),
                           @IN_TIPO       Char( 'N3_TIPO' ),
                           @IN_BAIXA      Char( 'N3_BAIXA' ),
                           @IN_SEQ        Char( 'N3_SEQ' ),
                           @IN_N1TPNEG    VarChar( 250 ),
                           @IN_N3TPNEG    VarChar( 250 ),
                           @IN_MOEDAATF   Char( 02 ),
                           @IN_LCALCULA   Char( 01 ),
                           @IN_DATADEP    Char( 08 ),
                           @IN_VCORRECAO  Float,
                           @IN_LMESCHEIO  Char( 01 ),
                           @IN_RECNO      integer </ri>
    Saida           - <o>  @OUT_TXDEP1    - Taxa mensal de depreciacao na moeda 1
                           @OUT_TXDEP2    - Taxa mensal de depreciacao na moeda 2
                           @OUT_TXDEP3    - Taxa mensal de depreciacao na moeda 3
                           @OUT_TXDEP4    - Taxa mensal de depreciacao na moeda 4
                           @OUT_TXDEP5    - Taxa mensal de depreciacao na moeda 5  </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     01/09/2006
-------------------------------------------------------------------------------------- */
Declare @cAux         VarChar( 03 )
Declare @cFilial_SN1  Char( 'N1_FILIAL' )
Declare @cFilial_SN4  Char( 'N4_FILIAL' )
Declare @nN3_PERCBAI  Float
Declare @cN3_DTBAIXA  Char( 08 )
Declare @cN3_DINDEPR  Char( 08 )
Declare @nN3_QUANTD   Float
Declare @nVORIG1      Float
Declare @nVORIG2      Float
Declare @nVORIG3      Float
Declare @nVORIG4      Float
Declare @nVORIG5      Float
Declare @nVRDACM1     Float
Declare @nVRDACM2     Float
Declare @nVRDACM3     Float
Declare @nVRDACM4     Float
Declare @nVRDACM5     Float
Declare @nAMPLIA1     Float
Declare @nAMPLIA2     Float
Declare @nAMPLIA3     Float
Declare @nAMPLIA4     Float
Declare @nAMPLIA5     Float
Declare @nTXDEPR1     Float
Declare @nTXDEPR2     Float
Declare @nTXDEPR3     Float
Declare @nTXDEPR4     Float
Declare @nTXDEPR5     Float
Declare @nPERCBAI     Float
Declare @nVRCDA1      Float
Declare @nVRCACM1     Float
Declare @cDataI       Char( 08 )
Declare @nTxMedia     Float
Declare @nTxMedia2    Float
Declare @nTxMedia3    Float
Declare @nTxMedia4    Float
Declare @nTxMedia5    Float
Declare @iNroDias     Integer
Declare @nOrigAtf     Float
Declare @nAmpliaAtf   Float
Declare @nValDeprAtf  Float
Declare @nVrdAcmAtf   Float
Declare @nValDepr1    Float
Declare @nValDepr2    Float
Declare @nValDepr3    Float
Declare @nValDepr4    Float
Declare @nValDepr5    Float
Declare @nDepr1       Float
Declare @nDepr2       Float
Declare @nDepr3       Float
Declare @nDepr4       Float
Declare @nDepr5       Float
Declare @nDiferenca1  Float
Declare @nDiferenca2  Float
Declare @nDiferenca3  Float
Declare @nDiferenca4  Float
Declare @nDiferenca5  Float
Declare @nParCorrec   Float
Declare @nTaxCor      Float
Declare @nVlrAtual    Float
Declare @nQuant       Float
Declare @nVlResidAtf  Float
Declare @nVlResid1    Float
Declare @nVlResid2    Float
Declare @nVlResid3    Float
Declare @nVlResid4    Float
Declare @nVlResid5    Float
Declare @iX           integer
Declare @iPos         integer
Declare @cChar        VarChar( 02 )
Declare @lN1TPNEG     Char( 01 )
Declare @lN3TPNEG     Char( 01 )
Declare @cTipoN3      Char( 02 )
Declare @nDiasDepr    Integer
Declare @nDias        Integer
Declare @cN1_PATRIM   Char( 01 )
Declare @nValCor      Float
Declare @nValCorDep   Float
Declare @nTaxaCor     Float
Declare @nUltimoDia   integer

begin
   Select @nValDepr1   = 0
   Select @nValDepr2   = 0
   Select @nValDepr3   = 0
   Select @nValDepr4   = 0
   Select @nValDepr5   = 0
   Select @nValCor     = 0
   Select @nValCorDep  = 0
   Select @nTxMedia    = 0
   
   If @IN_LMESCHEIO != '2' begin
      select @cAux = 'SN1'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SN1 OutPut
      select @cAux = 'SN4'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_SN4 OutPut
      Select @nParCorrec = @IN_VCORRECAO
      Select @nDiasDepr  = 0
      Select @nDias      = Convert( Int, Substring(@IN_DATADEP, 7,2) )
      Select @nTaxCor    = 0
      select @nQuant     = 0
      select @iX         = 1
      select @iPos       = 0
      select @nUltimoDia = Convert( integer, Substring(@IN_DATADEP, 7,2))
      /* -----------------------------------------------------------------------------
         1- Depreciacao acumulada na moeda 1,..,5 (N3_VRDACM1)
         2- Correcao da Depreciacao acumulada na moeda 1 - (N3_VRCDA1)
         3- Valor Original na moeda 1,..,5 (N3_VORIG1)
         4- Correcao acumulada do bem (N3_VRCACM1)
         5- Valor da ampliacao na moeda 1,..,5 - (N3_AMPLIA1)
         6- Taxa de depreciacao na moeda 1,..,5 - (N3_TXDEPR1)
         Funcao - Af050MonBas()
         -----------------------------------------------------------------------------*/   
      Select @nVORIG1  = N3_VORIG1,  @nVORIG2  = N3_VORIG2,  @nVORIG3  = N3_VORIG3,  @nVORIG4  = N3_VORIG4,  @nVORIG5  = N3_VORIG5,
             @nVRDACM1 = N3_VRDACM1, @nVRDACM2 = N3_VRDACM2, @nVRDACM3 = N3_VRDACM3, @nVRDACM4 = N3_VRDACM4, @nVRDACM5 = N3_VRDACM5,
             @nAMPLIA1 = N3_AMPLIA1, @nAMPLIA2 = N3_AMPLIA2, @nAMPLIA3 = N3_AMPLIA3, @nAMPLIA4 = N3_AMPLIA4, @nAMPLIA5 = N3_AMPLIA5,
             @nTXDEPR1 = N3_TXDEPR1, @nTXDEPR2 = N3_TXDEPR2, @nTXDEPR3 = N3_TXDEPR3, @nTXDEPR4 = N3_TXDEPR4, @nTXDEPR5 = N3_TXDEPR5,
             @nN3_PERCBAI = N3_PERCBAI, @nVRCDA1  = N3_VRCDA1,  @nVRCACM1 = N3_VRCACM1, @cN3_DTBAIXA = N3_DTBAIXA, @cN3_DINDEPR = N3_DINDEPR,
             @nN3_QUANTD  = N3_QUANTD
        From SN3###
       Where R_E_C_N_O_ = @IN_RECNO
      
      Select @nTXDEPR1  = @nTXDEPR1 / 1200
      Select @nTXDEPR2  = @nTXDEPR2 / 1200
      Select @nTXDEPR3  = @nTXDEPR3 / 1200
      Select @nTXDEPR4  = @nTXDEPR4 / 1200
      Select @nTXDEPR5  = @nTXDEPR5 / 1200
      
      select @cN1_PATRIM = N1_PATRIM
        From SN1###
       Where N1_FILIAL  = @cFilial_SN1
         and N1_CBASE   = @IN_CBASE
         and N1_ITEM    = @IN_ITEM
         and D_E_L_E_T_ = ' '
      
      select @nQuant = N4_QUANTD
        From SN4###
       Where N4_FILIAL  = @cFilial_SN4
         and N4_CBASE   = @IN_CBASE
         and N4_ITEM    = @IN_ITEM
         and N4_TIPO    = @IN_TIPO
         and N4_DATA    = @cN3_DTBAIXA
         and N4_OCORR   = '01'
         and N4_SEQ     = @IN_SEQ
         and N4_TIPOCNT = '1'
         and D_E_L_E_T_ = ' '
      /* -------------------------------------------------------------------
         Funcao - CalcDepre()
         ------------------------------------------------------------------- */
      select @cDataI = substring( @cN3_DTBAIXA, 1, 6 ) || '01'
      If @cN3_DINDEPR > @cDataI select @cDataI = @cN3_DINDEPR
      
      Select @nTxMedia2 = IsNull(Sum(M2_MOEDA2), 0 ), @nTxMedia3 = IsNull(Sum(M2_MOEDA3), 0),
             @nTxMedia4 = IsNull(Sum(M2_MOEDA4), 0) , @nTxMedia5 = IsNull(Sum(M2_MOEDA5), 0)
        From SM2###
       where M2_DATA between @cDataI and @cN3_DTBAIXA
         and D_E_L_E_T_ = ' '
      
      /* ----------------------------------------------------------------------------------
         Tratamento para o OpenEdge
         --------------------------------------------------------------------------------- */
      ##IF_001({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })
	    Select @iNroDias = ( DATEDIFF( DAY , @cDataI, @cN3_DTBAIXA ) )
	  ##ELSE_001
	    EXEC MSDATEDIFF 'DAY', @cDataI, @cN3_DTBAIXA, @iNroDias OutPut
	  ##ENDIF_001
      Select @iNroDias = @iNroDias + 1
      
      Select @nTxMedia2 = @nTxMedia2 / @iNroDias
      Select @nTxMedia3 = @nTxMedia3 / @iNroDias
      Select @nTxMedia4 = @nTxMedia4 / @iNroDias
      Select @nTxMedia5 = @nTxMedia5 / @iNroDias
      
      If @nTxMedia2 = 0 select @nTxMedia2 = 1
      If @nTxMedia3 = 0 select @nTxMedia3 = 1
      If @nTxMedia4 = 0 select @nTxMedia4 = 1
      If @nTxMedia5 = 0 select @nTxMedia5 = 1
      
      If @IN_MOEDAATF = '02' select @nTxMedia = @nTxMedia2
      If @IN_MOEDAATF = '03' select @nTxMedia = @nTxMedia3
      If @IN_MOEDAATF = '04' select @nTxMedia = @nTxMedia4
      If @IN_MOEDAATF = '05' select @nTxMedia = @nTxMedia5
      
      select @nOrigAtf    = 0
      select @nAmpliaAtf  = 0
      Select @nValDeprAtf = 0
      select @nVrdAcmAtf  = 0
      Select @nValDepr1   = 0
      Select @nValDepr2   = 0
      Select @nValDepr3   = 0
      Select @nValDepr4   = 0
      Select @nValDepr5   = 0
      Select @nDepr1      = 0
      Select @nDepr2      = 0
      Select @nDepr3      = 0
      Select @nDepr4      = 0
      Select @nDepr5      = 0
      Select @nValCor     = 0
      Select @nValCorDep  = 0
      /* -------------------------------------------------------------------
         Depreciacao nas moedas
         ------------------------------------------------------------------- */
      If @cN1_PATRIM IN ( ' ' ,'N' , 'D','I','O','T' ) begin
         If Abs(@nVRDACM1 + @nVRCACM1) < Abs(@nVORIG1 + @nVRCACM1 + @nAMPLIA1 ) begin
            If @nTXDEPR1 > 0 begin
               Select @nValDepr1 = Abs(@nVORIG1 + @nVRCACM1 + @nAMPLIA1) * @nTXDEPR1
               Select @nDiferenca1 = Abs(@nVORIG1 + @nVRCACM1 + @nAMPLIA1) - (Abs(@nValDepr1) + Abs(@nVRDACM1 + @nVRCDA1))
               If @nDiferenca1 <= 0 begin  
                  select @nDepr1 = @nDiferenca1
               end
            end
         end
         If Abs(@nVRDACM2) < Abs(@nVORIG2 + @nAMPLIA2 ) begin
            If @nTXDEPR2 > 0 begin
               Select @nValDepr2 = Abs(@nVORIG2 + @nAMPLIA2) * @nTXDEPR2
               Select @nDiferenca2 = Abs(@nVORIG2 + @nAMPLIA2) - (Abs(@nValDepr2) + Abs(@nVRDACM2))
               If @nDiferenca2 <= 0 begin
                  select @nDepr2 = @nDiferenca2
               end
            end
         end
         If Abs(@nVRDACM3) < Abs(@nVORIG3 + @nAMPLIA3 ) begin
            If @nTXDEPR3 > 0 begin
               Select @nValDepr3 = Abs(@nVORIG3 + @nAMPLIA3) * @nTXDEPR3
               Select @nDiferenca3 = Abs(@nVORIG3 + @nAMPLIA3) - (Abs(@nValDepr3) + Abs(@nVRDACM3))
               If @nDiferenca3 <= 0 begin
                  select @nDepr3 = @nDiferenca3
               end
            end
         end
         If Abs(@nVRDACM4) < Abs(@nVORIG4 + @nAMPLIA4 ) begin
            If @nTXDEPR4 > 0 begin
               Select @nValDepr4 = Abs(@nVORIG4 + @nAMPLIA4) * @nTXDEPR4
               Select @nDiferenca4 = Abs(@nVORIG4 + @nAMPLIA4) - (Abs(@nValDepr4) + Abs(@nVRDACM4))
               If @nDiferenca4 <= 0 begin
                  select @nDepr4 = @nDiferenca4
               end
            end
         end
         If Abs(@nVRDACM5) < Abs(@nVORIG5 + @nAMPLIA5 ) begin
            If @nTXDEPR5 > 0 begin
               Select @nValDepr5 = Abs(@nVORIG5 + @nAMPLIA5) * @nTXDEPR5
               Select @nDiferenca5 = Abs(@nVORIG5 + @nAMPLIA5) - (Abs(@nValDepr5) + Abs(@nVRDACM5))
               If @nDiferenca5 <= 0 begin
                  select @nDepr5 = @nDiferenca5
               end
            end
         end
         /* ----------------------------------------------------------------------------------
            Proporcionaliza as depreciacoes
            ---------------------------------------------------------------------------------- */
         If (@nUltimoDia <> @iNroDias) begin
            select @nValDepr1 = (@nValDepr1 / @nUltimoDia) * @iNroDias
            select @nValDepr2 = (@nValDepr2 / @nUltimoDia) * @iNroDias
            select @nValDepr3 = (@nValDepr3 / @nUltimoDia) * @iNroDias
            select @nValDepr4 = (@nValDepr4 / @nUltimoDia) * @iNroDias
            select @nValDepr5 = (@nValDepr5 / @nUltimoDia) * @iNroDias
         end
      end
      If @IN_MOEDAATF = '02' begin
         select @nOrigAtf    = @nVORIG2
         select @nAmpliaAtf  = @nAMPLIA2
         select @nValDeprAtf = @nValDepr2      
      end
      If @IN_MOEDAATF = '03' begin
         select @nOrigAtf    = @nVORIG3
         select @nAmpliaAtf  = @nAMPLIA3
         select @nValDeprAtf = @nValDepr3      
      end
      If @IN_MOEDAATF = '04' begin
         select @nOrigAtf    = @nVORIG4
         select @nAmpliaAtf  = @nAMPLIA4
         select @nValDeprAtf = @nValDepr4      
      end
      If @IN_MOEDAATF = '05' begin
         select @nOrigAtf    = @nVORIG5
         select @nAmpliaAtf  = @nAMPLIA5
         select @nValDeprAtf = @nValDepr5      
      end
   
      If @IN_LCALCULA = '1' begin
         select @nTaxaCor   = @nParCorrec
         select @nValCor    = ((Abs(@nOrigAtf + @nAmpliaAtf ) * @nTaxaCor) - Abs(@nVORIG1 + @nVRCACM1 + @nAMPLIA1 ) )
         select @nValCorDep = ((Abs(@nVrdAcmAtf + @nValDeprAtf) * @nTaxaCor) - (Abs(@nVRDACM1 + @nVRCDA1 + @nValDepr1)))
      end else begin
         If @cN3_DTBAIXA < '19941001'  begin
            If @IN_MOEDAATF = '02' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA2), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
            If @IN_MOEDAATF = '03' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA3), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
            If @IN_MOEDAATF = '04' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA4), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
            If @IN_MOEDAATF = '05' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA5), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
         end else begin
            select @nTaxaCor = 0
         end
         If @nTaxaCor <> 0 begin
            select @nValCor    = ((Abs(@nOrigAtf + @nAmpliaAtf ) * @nTaxaCor) - Abs(@nVORIG1 + @nVRCACM1 + @nAMPLIA1 ) )
            select @nValCorDep = ((Abs(@nVrdAcmAtf + @nValDeprAtf) * @nTaxaCor) - (Abs(@nVRDACM1 + @nVRCDA1 + @nValDepr1)))
            
            If @nQuant > 0 begin
               If @nQuant < @nN3_QUANTD select @nValCor = @nValCor / ( @nN3_QUANTD * @nQuant) 
               If @nQuant < @nN3_QUANTD select @nValCorDep = @nValCorDep / ( @nN3_QUANTD * @nQuant)
            end
         End
      end
      Select @nVlrAtual = @nVORIG1 + @nVRCACM1 + @nAMPLIA1 + @nValCor
      /* -------------------------------------------------------------------
         Depreciacao na moeda 1
         ------------------------------------------------------------------- */
      If @IN_LCALCULA = '1' begin
         If @nDepr1 = 0 begin
            select @nValDepr1 = @nValDeprAtf * @nParCorrec
         end
         select @nDiferenca1 = ((@nVORIG1 + @nVRCACM1 + @nAMPLIA1) + @nValCor) - (@nValDepr1 + @nVRDACM1 + @nVRCDA1)
         If @nDiferenca1 < 0 begin
            select @nDepr1 = ((@nVORIG1 + @nVRCACM1 + @nAMPLIA1 + @nValCor) - (@nVRDACM1 + @nVRCDA1 ))
         end
      end else begin
         If @cN3_DTBAIXA < '19960101' begin
            Select @nValDepr1 = @nValDeprAtf * @nTxMedia
            select @nDiferenca1 = ((@nVORIG1 + @nVRCACM1 + @nAMPLIA1) + @nValCor) - (@nValDepr1 + @nVRDACM1 + @nVRCDA1)
            If @nDiferenca1 <= 0 begin
               select @nDepr1 = ((@nVORIG1 + @nVRCACM1 + @nAMPLIA1) - (@nVRDACM1 + @nVRCDA1 ))
            end
         end
      end
      /* -------------------------------------------------------------------
         Trata residuos de depreciacao
         ------------------------------------------------------------------- */   
      Select @nVlResidAtf = 0
      Select @nVlResid1 = 0
      Select @nVlResid2 = 0
      Select @nVlResid3 = 0
      Select @nVlResid4 = 0
      Select @nVlResid5 = 0
      select @lN1TPNEG = '0'
      select @lN3TPNEG = '0'
      If @cN3_DINDEPR <= @cN3_DTBAIXA begin
         If @nDepr1 <> 0 select @nValDepr1 = @nDepr1
      End
      
      /* -------------------------------------------------------------------
         @IN_N1TPNEG = ""S/G/F""
         ------------------------------------------------------------------- */      
      While @iX <= Len(@IN_N1TPNEG) begin
         select @cChar = Substring( @IN_N1TPNEG, @iX, 1 )
         If @cChar = '"' or @cChar = '/' begin
            Select @iX = @iX+ 1
         end else begin
            If @cN1_PATRIM = @cChar begin
               select @lN1TPNEG = '1'
               Select @iX = Len(@IN_N1TPNEG)+1
            end else begin
               Select @iX = @iX+ 1
            end
         End
      End
      /* -------------------------------------------------------------------
         @IN_N3TPNEG = ""SE/FA""
         ------------------------------------------------------------------- */   
      select @iX = 1
      select @cChar = ''
      While @iX <= Len(@IN_N3TPNEG) begin
         select @cChar = Substring( @IN_N3TPNEG, @iX, 1 )
         If @cChar = '"' or @cChar = '/' begin
            Select @iX = @iX + 1
         End else begin
            Select @cTipoN3 = Substring( @IN_N3TPNEG, @iX, 2 )
            If @IN_TIPO = @cTipoN3 begin
               select @lN3TPNEG = '1'
               Select @iX = Len(@IN_N3TPNEG)+ 1
            end else begin
               Select @iX = @iX + 2
            end
         end
      End
      select @nVlResid1 = (@nVRDACM1 + @nVRCDA1)
      select @nVlResid2 = @nVRDACM2
      select @nVlResid3 = @nVRDACM3
      select @nVlResid4 = @nVRDACM4
      select @nVlResid5 = @nVRDACM5
      If ( @IN_TIPO = '05' or @lN1TPNEG = '1' or @lN3TPNEG = '1' ) begin
         select @nVlResid1 = (@nVORIG1 + @nAMPLIA1 + @nVRCACM1) + Abs( @nVlResid1 )
         select @nVlResid2 = (@nVORIG2 + @nAMPLIA1) + Abs( @nVlResid2 )
         select @nVlResid3 = (@nVORIG3 + @nAMPLIA3) + Abs( @nVlResid3 )
         select @nVlResid4 = (@nVORIG4 + @nAMPLIA4) + Abs( @nVlResid4 )
         select @nVlResid5 = (@nVORIG5 + @nAMPLIA5) + Abs( @nVlResid5 )
      end else begin
         select @nVlResid1 = Abs(@nVORIG1 + @nAMPLIA1 + @nVRCACM1 - @nVlResid1 )
         select @nVlResid2 = Abs(@nVORIG2 + @nAMPLIA2 - @nVlResid2 )
         select @nVlResid3 = Abs(@nVORIG3 + @nAMPLIA3 - @nVlResid3 )
         select @nVlResid4 = Abs(@nVORIG4 + @nAMPLIA4 - @nVlResid4 )
         select @nVlResid5 = Abs(@nVORIG5 + @nAMPLIA5 - @nVlResid5 )
      end
      
      If @IN_MOEDAATF = '02' select @nVlResidAtf = @nVlResid2
      If @IN_MOEDAATF = '03' select @nVlResidAtf = @nVlResid3
      If @IN_MOEDAATF = '04' select @nVlResidAtf = @nVlResid4
      If @IN_MOEDAATF = '05' select @nVlResidAtf = @nVlResid5
      
      If ( Substring( @cN3_DINDEPR, 5, 2 ) = Substring( @cN3_DTBAIXA, 5, 2 )) and
         ( Substring( @cN3_DINDEPR, 1, 4 ) = Substring( @cN3_DTBAIXA, 1, 4 )) begin
         
         /* ----------------------------------------------------------------------------------
            Tratamento para o OpenEdge
            --------------------------------------------------------------------------------- */
         ##IF_002({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })
           select @nDiasDepr = ( DATEDIFF( DAY , @cN3_DINDEPR, @cN3_DTBAIXA ) )
	     ##ELSE_002
	       EXEC MSDATEDIFF 'DAY', @cN3_DINDEPR, @cN3_DTBAIXA, @nDiasDepr OutPut
	     ##ENDIF_002
         select @nDiasDepr = @nDiasDepr + 1

      end else begin
         select @nDiasDepr = 0
      end
         
      If ( @IN_TIPO = '05' or @lN1TPNEG = '1' or @lN3TPNEG = '1' ) begin
         select @nVlResid1 = @nVlResid1 + @nValDepr1
         select @nVlResid2 = @nVlResid2 + @nValDepr2
         select @nVlResid3 = @nVlResid3 + @nValDepr3
         select @nVlResid4 = @nVlResid4 + @nValDepr4
         select @nVlResid5 = @nVlResid5 + @nValDepr5
      end else begin
         select @nVlResid1 = @nVlResid1 - @nVlResid1
         select @nVlResid2 = @nVlResid2 - @nValDepr2
         select @nVlResid3 = @nVlResid3 - @nValDepr3
         select @nVlResid4 = @nVlResid4 - @nValDepr4
         select @nVlResid5 = @nVlResid5 - @nValDepr5
      end
            
      If @nDepr1 <> 0 Select @nValDepr1 = @nDepr1
      If @nDepr2 <> 0 Select @nValDepr2 = @nDepr2
      If @nDepr3 <> 0 Select @nValDepr3 = @nDepr3
      If @nDepr4 <> 0 Select @nValDepr4 = @nDepr4
      If @nDepr5 <> 0 Select @nValDepr5 = @nDepr5
      
      Select @nVRCDA1   = @nVRCDA1 / @nN3_PERCBAI   --  VER
      /* ------------------------------------------------------------------------
         Calculo de Correcao da correcao do bem e da depreciacao.
         A taxa de correcao e a mesma para o custo e p/ depr acumulada.
         ------------------------------------------------------------------------*/
      If @IN_LCALCULA ='1'  begin
         select @nTaxaCor   = @nParCorrec
         select @nValCor    = ((Abs(@nOrigAtf + @nAmpliaAtf ) * @nTaxaCor) - Abs(@nVORIG1 + @nVRCACM1 + @nAMPLIA1 ) )
         select @nValCorDep = ((Abs(@nVrdAcmAtf + @nValDeprAtf) * @nTaxaCor) - (Abs(@nVRDACM1 + @nVRCDA1 + @nValDepr1)))
         
         If @nQuant > 0 begin
            If @nQuant < @nN3_QUANTD select @nValCor = ( @nValCor / @nN3_QUANTD ) * @nQuant
            If @nQuant < @nN3_QUANTD select @nValCorDep = ( @nValCorDep / @nN3_QUANTD ) * @nQuant
         end
      end else begin
         If @cN3_DTBAIXA < '19941001'  begin
            If @IN_MOEDAATF = '02' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA2), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
            If @IN_MOEDAATF = '03' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA3), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
            If @IN_MOEDAATF = '04' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA4), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
            If @IN_MOEDAATF = '05' begin
               Select @nTaxaCor = IsNull(Sum(M2_MOEDA5), 0 )
                 From SM2###
                where M2_DATA = @cN3_DTBAIXA
                  and D_E_L_E_T_ = ' '
            end
         end else begin
            select @nTaxaCor = 0
         end
         If @nTaxaCor <> 0 begin
            select @nValCor    = ((Abs(@nOrigAtf + @nAmpliaAtf ) * @nTaxaCor) - Abs(@nVORIG1 + @nVRCACM1 + @nAMPLIA1 ) )
            select @nValCorDep = ((Abs(@nVrdAcmAtf + @nValDeprAtf) * @nTaxaCor) - (Abs(@nVRDACM1 + @nVRCDA1 + @nValDepr1)))
            
            If @nQuant > 0 begin
               If @nQuant < @nN3_QUANTD select @nValCor = ( @nValCor / @nN3_QUANTD ) * @nQuant
               If @nQuant < @nN3_QUANTD select @nValCorDep = ( @nValCorDep / @nN3_QUANTD ) * @nQuant
            end
         End
      End
   End
   select @OUT_DEPR1   = @nValDepr1
   select @OUT_DEPR2   = @nValDepr2
   select @OUT_DEPR3   = @nValDepr3
   select @OUT_DEPR4   = @nValDepr4
   select @OUT_DEPR5   = @nValDepr5
   Select @OUT_COR     = @nValCor
   Select @OUT_CORDEP  = @nValCorDep
   Select @OUT_TXMEDIA = @nTxMedia
end
