##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##FIELDP01( 'CT2.CT2_EC09DB' )
Create Procedure CTB208_## (
   @IN_LATUAL Char( 01 ),
   @IN_CUBO   Char( 'CT0_ID' ),
   @IN_FILIAL Char( 'CT2_FILIAL' ), 
   @IN_MOEDA  Char( 'CT2_MOEDLC' ),
   @IN_TPSALD Char( 'CT2_TPSALD' ), 
   @IN_DATA   Char( 08 ),
   @IN_CONTA  Char( 'CT2_DEBITO' ),
   @IN_CUSTO  Char( 'CT2_CCD' ),
   @IN_ITEM   Char( 'CT2_ITEMD' ),
   @IN_CLVL   Char( 'CT2_CLVLDB' ),
   @IN_NIV05  Char( 'CT2_EC05DB' ),
   @IN_NIV06  Char( 'CT2_EC06DB' ),
   @IN_NIV07  Char( 'CT2_EC07DB' ),
   @IN_NIV08  Char( 'CT2_EC08DB' ),
   @IN_NIV09  Char( 'CT2_EC09DB' ),
   @IN_VALORD float,
   @IN_VALORC float
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ctbxatu.prx </s>
    Descricao       - <d>  Atualizar Cubo 09 - NIV09 </d>
    Funcao do Siga  -      ctbxfun
    Entrada         - <ri> @IN_LATUAL   - Se '1' atualiza CVX, se '2' atualiza CVY e se '3', Atualiza Ambas
                           @IN_CUBO     - Cubo a ser atualizado
                           @IN_FILIAL   - Filial onde a manutencao sera feita
                           @IN_MOEDA    - Moeda aAtualizar
                           @IN_TPSALD   - Tipo de saldo a atualizar
                           @IN_DATA     - Data da Atualizacao
                           @IN_CONTA    - Conta a atualizar
                           @IN_CUSTO    - CCusto a atualizar
                           @IN_ITEM     - Item a atualizar
                           @IN_CLVL     - Clvl a atualizar
                           @IN_NIV05    - entidade de Nivel 05 
                           @IN_NIV06    - entidade de Nivel 06 
                           @IN_NIV07    - entidade de Nivel 07 
                           @IN_NIV08    - entidade de Nivel 08 
                           @IN_NIV09    - entidade de Nivel 09
                           @IN_VALORD   - Valor a adicionar no Debito
                           @IN_VALORC   - Valor a adicionar no Credito
    Saida           - <o>   </ro>
    Data        :     14/04/2010
   ------------------------------------------------------------------------------------- */
Declare @iRecnoCVX integer
Declare @iRecnoCVY integer
Declare @nValDeb   float
Declare @nValCrd   float
Declare @cConfig   Char( 'CVX_CONFIG' )
Declare @cDataF    Char( 08 )
Declare @cAux      Char( 03 )
Declare @cFilial_CVX Char( 'CT2_FILIAL' )
Declare @cFilial_CVY Char( 'CT2_FILIAL' )

begin
   
   select @cConfig = @IN_CUBO
   select @nValDeb = @IN_VALORD
   select @nValCrd = @IN_VALORC
   /*--------------------------------------------------------------------
      Atualizacao do CVX
     -------------------------------------------------------------------- */
   If @IN_LATUAL in ( '1', '3' ) begin
   
      select @cAux    = 'CVX'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CVX OutPut
      select @iRecnoCVX = 0
   
      Select @iRecnoCVX = IsNull(Max(R_E_C_N_O_), 0)
        From CVX###
       where CVX_FILIAL = @cFilial_CVX
         and CVX_CONFIG = @cConfig
         and CVX_MOEDA  = @IN_MOEDA
         and CVX_TPSALD = @IN_TPSALD
         and CVX_DATA   = @IN_DATA
         and CVX_NIV01  = @IN_CONTA
         and CVX_NIV02  = @IN_CUSTO
         and CVX_NIV03  = @IN_ITEM
         and CVX_NIV04  = @IN_CLVL
         and CVX_NIV05  = @IN_NIV05
         and CVX_NIV06  = @IN_NIV06
         and CVX_NIV07  = @IN_NIV07
         and CVX_NIV08  = @IN_NIV08
         and CVX_NIV09  = @IN_NIV09
         and D_E_L_E_T_ = ' '
      
      If @iRecnoCVX is null or @iRecnoCVX = 0 begin
         select @iRecnoCVX = 0
         select @iRecnoCVX = IsNull(max(R_E_C_N_O_), 0 ) from CVX###
         select @iRecnoCVX = @iRecnoCVX + 1
         
         ##TRATARECNO\@iRecnoCVX
         begin tran
         insert into CVX### ( CVX_FILIAL,   CVX_CONFIG, CVX_MOEDA, CVX_DATA,  CVX_TPSALD, CVX_SLDCRD, CVX_SLDDEB, CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04,
                              CVX_NIV05,    CVX_NIV06,  CVX_NIV07, CVX_NIV08, CVX_NIV09,  R_E_C_N_O_  )
                     values ( @cFilial_CVX, @cConfig,   @IN_MOEDA, @IN_DATA,  @IN_TPSALD, @nValCrd,   @nValDeb,   @IN_CONTA, @IN_CUSTO, @IN_ITEM,  @IN_CLVL,
                              @IN_NIV05,    @IN_NIV06,  @IN_NIV07, @IN_NIV08, @IN_NIV09,  @iRecnoCVX )
         commit tran
         ##FIMTRATARECNO
      end else begin
         begin tran
         Update CVX###
            Set CVX_SLDDEB = CVX_SLDDEB + @nValDeb, CVX_SLDCRD = CVX_SLDCRD + @nValCrd
           Where R_E_C_N_O_ = @iRecnoCVX
         commit tran
      End
   End   
   /*--------------------------------------------------------------------
      Atualizacao do CVY
     -------------------------------------------------------------------- */
   If @IN_LATUAL in ( '2', '3' ) begin
      select @cAux    = 'CVY'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CVY OutPut
      Exec LASTDAY_## @IN_DATA, @cDataF output
      select @iRecnoCVY = 0
      
      Select @iRecnoCVY = IsNull(Max(R_E_C_N_O_), 0)
        From CVY###
       where CVY_FILIAL = @cFilial_CVY
         and CVY_CONFIG = @cConfig
         and CVY_MOEDA  = @IN_MOEDA
         and CVY_TPSALD = @IN_TPSALD
         and CVY_DATA   = @cDataF
         and CVY_NIV01  = @IN_CONTA
         and CVY_NIV02  = @IN_CUSTO
         and CVY_NIV03  = @IN_ITEM
         and CVY_NIV04  = @IN_CLVL
         and CVY_NIV05  = @IN_NIV05
         and CVY_NIV06  = @IN_NIV06
         and CVY_NIV07  = @IN_NIV07
         and CVY_NIV08  = @IN_NIV08
         and CVY_NIV09  = @IN_NIV09
         and D_E_L_E_T_ = ' '
         
      If @iRecnoCVY is null or @iRecnoCVY = 0 begin
         select @iRecnoCVY = 0
         select @iRecnoCVY = IsNull(max(R_E_C_N_O_), 0 ) from CVY###
         select @iRecnoCVY = @iRecnoCVY + 1
         
         ##TRATARECNO\@iRecnoCVY
         begin tran
         insert into CVY### ( CVY_FILIAL,   CVY_CONFIG, CVY_MOEDA, CVY_DATA,  CVY_TPSALD, CVY_SLDCRD, CVY_SLDDEB, CVY_NIV01, CVY_NIV02, CVY_NIV03, CVY_NIV04,
                              CVY_NIV05,    CVY_NIV06,  CVY_NIV07, CVY_NIV08, CVY_NIV09,  R_E_C_N_O_ )
                     values ( @cFilial_CVY, @cConfig,   @IN_MOEDA, @cDataF,   @IN_TPSALD, @nValCrd,   @nValDeb,   @IN_CONTA, @IN_CUSTO, @IN_ITEM,  @IN_CLVL,
                              @IN_NIV05,    @IN_NIV06,  @IN_NIV07, @IN_NIV08, @IN_NIV09,  @iRecnoCVY )
         commit tran
         ##FIMTRATARECNO
      end else begin
         begin tran
         Update CVY###
            Set CVY_SLDDEB = CVY_SLDDEB + @nValDeb, CVY_SLDCRD = CVY_SLDCRD + @nValCrd
           Where R_E_C_N_O_ = @iRecnoCVY
         commit tran
      End
   End
End
##ENDFIELDP01
##ENDIF_001
