Create procedure CTB003_##
 ( 
   @IN_FILIALCOR  Char( 'CT1_FILIAL' ),
   @IN_CV1_CTHINI Char( 'CV1_CTHINI' ),
   @IN_CV1_CTHFIM Char( 'CV1_CTHFIM' ),
   @IN_CV1_CTDINI Char( 'CV1_CTDINI' ),
   @IN_CV1_CTDFIM Char( 'CV1_CTDFIM' ),
   @IN_CV1_CTTINI Char( 'CV1_CTTINI' ),
   @IN_CV1_CTTFIM Char( 'CV1_CTTFIM' ),
   @IN_CV1_CT1INI Char( 'CV1_CT1INI' ),
   @IN_CV1_CT1FIM Char( 'CV1_CT1FIM' ),
   @IN_CV1_MOEDA  Char( 'CV1_MOEDA' ),
   @IN_CV1_DTFIM  Char( 'CV1_DTFIM' ),
   @IN_CV1_VALOR  Float,
   @IN_COPERACAO  Char( 01 ),
   @IN_OPCAOX     Char( 01 ),
   @IN_DATAANT    Char( 08 ),
   @IN_CONTAANT   Char( 'CV1_CT1INI' ),
   @IN_CUSTOANT   Char( 'CV1_CTTINI' ),
   @IN_ITEMANT    Char( 'CV1_CTDINI' ),
   @IN_CLVLANT    Char( 'CV1_CTHINI' ),
   @OUT_RESULTADO Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Reprocessamento SigaCTB </d>
    Funcao do Siga  -     Ctb390Atu()
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial Corrente
                           @IN_CV1_CTHINI - ClVl Inicial
                           @IN_CV1_CTHFIM - ClVl Final
                           @IN_CV1_CTDINI - Item Inicial
                           @IN_CV1_CTDFIM - Item Final
                           @IN_CV1_CTTINI - CCusto Inicial
                           @IN_CV1_CTTFIM - CCusto Final
                           @IN_CV1_CT1INI - Conta Inicial
                           @IN_CV1_CT1FIM - Conta Final
                           @IN_CV1_MOEDA  - Moeda
                           @IN_CV1_DTFIM  - Data Fim
                           @IN_CV1_VALOR  - Valor
                           @IN_COPERACAO  - Operacao
                           @IN_OPCAOX     - opcao, inclusao, alteracao
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CQ0 char( 'CQ0_FILIAL' )
declare @cFilial_CQ2 char( 'CQ2_FILIAL' )
declare @cFilial_CQ4 char( 'CQ4_FILIAL' )
declare @cFilial_CQ6 char( 'CQ6_FILIAL' )

declare @cFilial_CTD char( 'CT1_FILIAL' )
declare @cFilial_CTH char( 'CT1_FILIAL' )
declare @cFilial_CTT char( 'CT1_FILIAL' )

declare @cAux        char( 03 )
declare @iFatorCTH   int
declare @iFatorCTD   int
declare @iFatorCTT   int
declare @cOpcaoX     char( 01 )
declare @cCT1        char( 01 )
declare @cCTT        char( 01 )
declare @cCTD        char( 01 )
declare @cCTH        char( 01 )
declare @OutRetorno  char( 01 )

begin
   
   select @OutRetorno = '0'
   select @cAux = 'CTT'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTT OutPut
   select @cAux = 'CTD'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTD OutPut
   select @cAux = 'CTH'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTH OutPut
   
   select @cAux = 'CQ0'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ0 OutPut
   select @cAux = 'CQ2'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ2 OutPut
   select @cAux = 'CQ4'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ4 OutPut
   select @cAux = 'CQ6'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ6 OutPut
   
   if ( @IN_OPCAOX = ' ' ) select @cOpcaoX = '3'
   else select @cOpcaoX = @IN_OPCAOX
   
   select @iFatorCTH  = 1
   select @iFatorCTD  = 1
   select @iFatorCTT  = 1
   
   select @cCT1 = '0'
   select @cCTD = '0'
   select @cCTH = '0'
   select @cCTT = '0'
   /* -----------------------------------------------------------------------------------------------------------
      Fator entidades - CTB390Recn() - Rotina que o numero de entidades do intervalo para cada uma das entidades.
      CTH -> CTH1 até CTH5 => Fator = 5
      ------------------------------------------------------------------------------------------------------------ */
   If ( @cOpcaoX = '3' and ( @IN_CV1_CTHINI != ' ' or @IN_CV1_CTHFIM != ' ' ) )
      or ( @cOpcaoX = '4' and ( @IN_CV1_CTHINI != ' ' or @IN_CV1_CTHFIM != ' '
                           or @IN_CV1_CTHINI != ' ' or @IN_CV1_CTHFIM != ' ' ) )
      or ( @cOpcaoX = '5' and ( @IN_CV1_CTHINI != ' ' or @IN_CV1_CTHFIM != ' ' ) ) begin
      
      select @cCTH = '1' 
      select @cAux = 'CTH'
      EXEC CTB011_## @cFilial_CTH, @cAux, @IN_CV1_CTHINI, @IN_CV1_CTHFIM, @iFatorCTH Output
      
   end
   
   If ( @cOpcaoX = '3' and ( @IN_CV1_CTDINI != ' ' or @IN_CV1_CTDFIM != ' ' ) )
      or ( @cOpcaoX = '4' and ( @IN_CV1_CTDINI != ' ' or @IN_CV1_CTDFIM != ' '
                           or @IN_CV1_CTDINI != ' ' or @IN_CV1_CTDFIM != ' ' ) )
      or ( @cOpcaoX = '5' and ( @IN_CV1_CTDINI != ' ' or @IN_CV1_CTDFIM != ' ' ) ) begin
      
      select @cCTD = '1'
      select @cAux = 'CTD'
      EXEC CTB011_## @cFilial_CTD, @cAux, @IN_CV1_CTDINI, @IN_CV1_CTDFIM, @iFatorCTD Output
      
   end
   
   If ( @cOpcaoX = '3' and ( @IN_CV1_CTTINI != ' ' or @IN_CV1_CTTFIM != ' ' ) )
      or ( @cOpcaoX = '4' and ( @IN_CV1_CTTINI != ' ' or @IN_CV1_CTTFIM != ' '
                           or @IN_CV1_CTTINI != ' ' or @IN_CV1_CTTFIM != ' ' ) )
      or ( @cOpcaoX = '5' and ( @IN_CV1_CTTINI != ' ' or @IN_CV1_CTTFIM != ' ' ) ) begin
      select @cCTT = '1'
      select @cAux = 'CTT'
      EXEC CTB011_## @cFilial_CTT, @cAux, @IN_CV1_CTTINI, @IN_CV1_CTTFIM, @iFatorCTT Output
      
   end
   
   If ( @cOpcaoX = '3' and ( @IN_CV1_CT1INI != ' ' or @IN_CV1_CT1FIM != ' ' ) )
      or ( @cOpcaoX = '4' and ( @IN_CV1_CT1INI != ' ' or @IN_CV1_CT1FIM != ' '
                           or @IN_CV1_CT1INI != ' ' or @IN_CV1_CT1FIM != ' ' ) )
      or ( @cOpcaoX = '5' and ( @IN_CV1_CT1INI != ' ' or @IN_CV1_CT1FIM != ' ' ) ) begin
      
      select @cCT1 = '1'
   end
   /* ------------------------------------------------------------
      Ctb390CTI()  - Grava os saldos do arquivo CQ6/CQ7 - ClVl
      ------------------------------------------------------------ */
   if ( @cCTH = '1' ) begin
      exec CTB010_## @cFilial_CQ6,   @IN_CV1_CTHINI, @IN_CV1_CTHFIM, @IN_CV1_CTDINI, @IN_CV1_CTDFIM,
                     @IN_CV1_CTTINI, @IN_CV1_CTTFIM, @IN_CV1_CT1INI, @IN_CV1_CT1FIM, @cCT1,
                     @cCTT,          @cCTD,          @cCTH,          @IN_CV1_MOEDA,  @IN_CV1_DTFIM,
                     @IN_CV1_VALOR,  @IN_COPERACAO,  @OutRetorno Output
   end
   
   /* ------------------------------------------------------------
      Ctb390CTD()  - Grava os saldos do arquivo CQ4/CQ5  - Item
      ------------------------------------------------------------*/
  if ( @cCTD = '1' ) begin
      select @OutRetorno = '0'
      exec CTB004_## @cFilial_CQ4,   @IN_CV1_CTDINI, @IN_CV1_CTDFIM, @IN_CV1_CTTINI, @IN_CV1_CTTFIM,
                     @IN_CV1_CT1INI, @IN_CV1_CT1FIM, @cCT1,          @cCTT,          @IN_CV1_MOEDA,
                     @IN_CV1_DTFIM,  @IN_CV1_VALOR,  @IN_COPERACAO,  @iFatorCTH,     @OutRetorno Output
   end
   /* ------------------------------------------------------------
      Ctb390CTT()  - Grava os saldos do arquivo CQ2/CQ3  - CUSTO
      ------------------------------------------------------------*/
   if ( @cCTT = '1' ) begin
      select @OutRetorno = '0'
      exec CTB005_## @cFilial_CQ2, @IN_CV1_CTTINI, @IN_CV1_CTTFIM, @IN_CV1_CT1INI, @IN_CV1_CT1FIM,
                     @cCT1,        @IN_CV1_MOEDA,  @IN_CV1_DTFIM,  @IN_CV1_VALOR,  @IN_COPERACAO,
                     @iFatorCTH,   @iFatorCTD,     @OutRetorno Output
   end
   /* ------------------------------------------------------------
      Ctb390CT1()  - Grava os saldos do arquivo CQ0/CQ1  - CONTA
      ------------------------------------------------------------*/
   if ( @cCT1 = '1' ) begin
      select @OutRetorno = '0'
      exec CTB006_## @cFilial_CQ0,  @IN_CV1_CT1INI, @IN_CV1_CT1FIM, @cCT1,      @IN_CV1_MOEDA,
                     @IN_CV1_DTFIM, @IN_CV1_VALOR,  @IN_COPERACAO,  @iFatorCTH, @iFatorCTD,
                     @iFatorCTT,    @OutRetorno Output
   end
   
   
   select @OUT_RESULTADO = @OutRetorno
end

