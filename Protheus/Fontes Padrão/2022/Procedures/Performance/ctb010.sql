Create procedure CTB010_##
 ( 
   @IN_FILIALCOR  Char('CV1_FILIAL'),
   @IN_CV1_CTHINI Char('CV1_CTHINI'),
   @IN_CV1_CTHFIM Char('CV1_CTHFIM'),
   @IN_CV1_CTDINI Char('CV1_CTDINI'),
   @IN_CV1_CTDFIM Char('CV1_CTDFIM'),
   @IN_CV1_CTTINI Char('CV1_CTTINI'),
   @IN_CV1_CTTFIM Char('CV1_CTTFIM'),
   @IN_CV1_CT1INI Char('CV1_CT1INI'),
   @IN_CV1_CT1FIM Char('CV1_CT1FIM'),
   @IN_CT1        Char(01),
   @IN_CTT        Char(01),
   @IN_CTD        Char(01),
   @IN_CTH        Char(01),
   @IN_CV1_MOEDA  Char('CV1_MOEDA'),
   @IN_CV1_DTFIM  Char('CV1_DTFIM'),
   @IN_CV1_VALOR  Float,
   @IN_COPERACAO  Char(01),
   @OUT_RESULTADO Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Grava os saldos do arquivo CTI. </d>
    Funcao do Siga  -     Ctb390CTI()  - Grava os saldos do arquivo CTI.
    Fonte Microsiga - <s> CTBA390.PRW </s>
    Entrada         - <ri> @IN_FILIALCOR  - Filial
                           @IN_CV1_CTHINI - ClVl Inicial
                           @IN_CV1_CTHFIM - ClVl Final
                           @IN_CV1_CTDINI - Item Inicial
                           @IN_CV1_CTDFIM - Item Final
                           @IN_CV1_CTTINI - CCusto Inicial
                           @IN_CV1_CTTFIM - CCutso Final
                           @IN_CV1_CT1INI - Conta Inicial
                           @IN_CV1_CT1FIM - Conta Final
                           @IN_CT1        - Flag Conta Orcada
                           @IN_CTT        - Flag CCusto Orcado
                           @IN_CTD        - Flag Item Orcado
                           @IN_CTH        - Flag ClVl Orcado
                           @IN_CV1_MOEDA  - Moeda
                           @IN_CV1_DTFIM  - Data
                           @IN_CV1_VALOR  - Valor
                           @IN_COPERACAO  - Operacao
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r> Marco Norbiato	</r>
    Data        :     19/09/2003
-------------------------------------------------------------------------------------- */
declare @cFilial_CQ6   char('CQ6_FILIAL')
declare @cFilial_CQ7   char('CQ7_FILIAL')
declare @cFilial_CQ8   char('CQ8_FILIAL')
declare @cFilial_CQ9   char('CQ9_FILIAL')
declare @cFilial_CT1   char('CT1_FILIAL')
declare @cFilial_CTT   char('CTT_FILIAL')
declare @cFilial_CTD   char('CTD_FILIAL')
declare @cFilial_CTH   char('CTH_FILIAL')
declare @cAux          char(03)
declare @iRecno        int
declare @cCTXX_CONTA   char('CT1_CONTA')
declare @cCTXX_NORMAL  char('CT1_NORMAL')
declare @cCTXX_CUSTO   char('CTT_CUSTO')
declare @cCTXX_ITEM    char('CTD_ITEM')
declare @cCTXX_CLVL    char('CTH_CLVL')
declare @nCTXX_DEBITO  Float
declare @nCTXX_CREDIT  Float
declare @cTpSaldo      Char('CQ6_TPSALD')
declare @cStatus       Char('CQ6_STATUS')
declare @cSlBase       Char('CQ6_SLBASE')
declare @cDataF        Char(08)
declare @cDtLp         Char(08)
declare @cLp           Char('CQ6_LP')
declare @iRepete       Integer

begin
   
   select @cAux = 'CQ6'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ6 OutPut
   select @cAux = 'CQ7'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ7 OutPut
   select @cAux = 'CQ8'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ8 OutPut
   select @cAux = 'CQ9'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CQ9 OutPut   
   select @cAux = 'CT1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CT1 OutPut
   select @cAux = 'CTT'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTT OutPut
   select @cAux = 'CTD'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTD OutPut
   select @cAux = 'CTH'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_CTH OutPut
   
   select @OUT_RESULTADO = '0'
   Select @cCTXX_NORMAL = ' '
   Select @nCTXX_DEBITO = 0
   Select @nCTXX_CREDIT = 0
      
   If ( ( @IN_CV1_CT1INI = @IN_CV1_CT1FIM ) and ( @IN_CV1_CTTINI = @IN_CV1_CTTFIM ) and 
        ( @IN_CV1_CTDINI = @IN_CV1_CTDFIM ) and ( @IN_CV1_CTHINI = @IN_CV1_CTHFIM ) )  begin
      /* ------------------------------------------------------------
         Gera Saldo quando todas as entidades são iguais
         ------------------------------------------------------------*/      
      Exec CTB013_##  @IN_FILIALCOR, @IN_CV1_CTHINI, @IN_CV1_CTDINI, @IN_CV1_CTTINI, @IN_CV1_CT1INI, @IN_CT1,
                      @IN_CTT,       @IN_CTD,        @IN_CTH,        @IN_CV1_MOEDA,  @IN_CV1_DTFIM,  @IN_CV1_VALOR,
                      @IN_COPERACAO, @OUT_RESULTADO OutPut
      
   end else begin
   /* ------------------------------------------------------------
      Repete = '1' -> insert nas tabelas de saldos
       obs: qdo @IN_CT1 = '0' NÃO se deveria incluir dado
      repete = '2' -> updates na tabelas de saldos
      ------------------------------------------------------------*/
      select @iRepete = 1  
      Exec LASTDAY_## @IN_CV1_DTFIM, @cDataF OutPut
      
      While @iRepete <= 2 begin
         If @iRepete = 1 begin
            If @IN_CTD = '0' and @IN_CTT = '0' and @IN_CT1 = '0' begin
               declare Ctb390CQ7_A Insensitive cursor for
               Select CTH_CLVL
                 From CTH### CTH
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and  @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ7### CQ7
                             Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                               and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                               and CQ7.CQ7_ITEM   = ' '
                               and CQ7.CQ7_CCUSTO = ' '
                               and CQ7.CQ7_CONTA  = ' '
                               and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                               and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                               and CQ7.CQ7_TPSALD = '0'
                               and CQ7.D_E_L_E_T_ = ' ' ) 
               for read only
               open Ctb390CQ7_A
               fetch Ctb390CQ7_A into @cCTXX_CLVL
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_ITEM   = ' '
                  select @cCTXX_CUSTO  = ' '
                  select @cCTXX_CONTA  = ' '
                  
                  select @cTpSaldo = '0'
                  select @cStatus  = '1'
                  select @cSlBase  = 'S'
                  select @cDtLp    = ' '
                  select @cLp      = 'N'
                  
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
 
				  SELECT @fim_CUR = 0                 
                  fetch Ctb390CQ7_A into @cCTXX_CLVL
               end
               close      Ctb390CQ7_A
               deallocate Ctb390CQ7_A
            End
            
            If @IN_CTD = '1' and @IN_CTT = '0' and @IN_CT1 = '0' begin
               declare Ctb390CQ7_B Insensitive cursor for
               Select CTH_CLVL, CTD_ITEM
                 From CTH### CTH, CTD### CTD
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ7### CQ7
                             Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                               and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                               and CQ7.CQ7_ITEM   = CTD.CTD_ITEM
                               and CQ7.CQ7_CCUSTO = ' '
                               and CQ7.CQ7_CONTA  = ' '
                               and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                               and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                               and CQ7.CQ7_TPSALD = '0'
                               and CQ7.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ7_B
               fetch Ctb390CQ7_B into @cCTXX_CLVL, @cCTXX_ITEM
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_CUSTO  = ' '
                  select @cCTXX_CONTA  = ' '
                  
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
 
				  SELECT @fim_CUR = 0                 
                  fetch Ctb390CQ7_B into @cCTXX_CLVL, @cCTXX_ITEM
               end
               close      Ctb390CQ7_B
               deallocate Ctb390CQ7_B
               
            End
            
            If @IN_CTD = '0' and @IN_CTT = '1' and @IN_CT1 = '0' begin
               declare Ctb390CQ7_C Insensitive cursor for
               Select CTH_CLVL, CTT_CUSTO
                 From CTH### CTH, CTT### CTT
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ7### CQ7
                             Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                               and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                               and CQ7.CQ7_ITEM   = ' '
                               and CQ7.CQ7_CCUSTO = CTT.CTT_CUSTO
                               and CQ7.CQ7_CONTA  = ' '
                               and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                               and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                               and CQ7.CQ7_TPSALD = '0'
                               and CQ7.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ7_C
               fetch Ctb390CQ7_C into @cCTXX_CLVL, @cCTXX_CUSTO
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_ITEM   = ' '
                  select @cCTXX_CONTA  = ' '
                  
                  select @cTpSaldo = '0'
                  select @cStatus  = '1'
                  select @cSlBase  = 'S'
                  select @cDtLp    = ' '
                  select @cLp      = 'N'
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO


				  SELECT @fim_CUR = 0                  
                  fetch Ctb390CQ7_C into @cCTXX_CLVL, @cCTXX_CUSTO
               end
               close      Ctb390CQ7_C
               deallocate Ctb390CQ7_C
               
            End
            
            If @IN_CTD = '0' and @IN_CTT = '0' and @IN_CT1 = '1' begin
               declare Ctb390CQ7_D Insensitive cursor for
               Select CTH_CLVL, CT1_NORMAL, CT1_CONTA
                 From CTH### CTH, CT1### CT1
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and CT1.CT1_FILIAL = @cFilial_CT1
                  and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CT1.CT1_CLASSE = '2'
                  and CT1.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                                     From CQ7### CQ7
                                    Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                                      and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                                      and CQ7.CQ7_ITEM   = ' '
                                      and CQ7.CQ7_CCUSTO = ' '
                                      and CQ7.CQ7_CONTA  = CT1.CT1_CONTA
                                      and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                                      and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                                      and CQ7.CQ7_TPSALD = '0'
                                      and CQ7.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ7_D
               fetch Ctb390CQ7_D into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_CONTA
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_ITEM   = ' '
                  select @cCTXX_CUSTO  = ' '
                  
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  
		          SELECT @fim_CUR = 0                 
                  fetch Ctb390CQ7_D into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_CONTA
               end
               close      Ctb390CQ7_D
               deallocate Ctb390CQ7_D
               
            End
            
            If @IN_CTD = '1' and @IN_CTT = '1' and @IN_CT1 = '0' begin
               declare Ctb390CQ7_E Insensitive cursor for
               Select CTH_CLVL, CTD_ITEM, CTT_CUSTO
                 From CTH### CTH, CTD### CTD, CTT### CTT
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ7### CQ7
                             Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                               and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                               and CQ7.CQ7_ITEM   = CTD.CTD_ITEM
                               and CQ7.CQ7_CCUSTO = CTT.CTT_CUSTO
                               and CQ7.CQ7_CONTA  = ' '
                               and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                               and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                               and CQ7.CQ7_TPSALD = '0'
                               and CQ7.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ7_E
               fetch Ctb390CQ7_E into @cCTXX_CLVL, @cCTXX_ITEM, @cCTXX_CUSTO
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_CONTA  = ' '
                  
                  select @cTpSaldo = '0'
                  select @cStatus  = '1'
                  select @cSlBase  = 'S'
                  select @cDtLp    = ' '
                  select @cLp      = 'N'
                   
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO

				  SELECT @fim_CUR = 0
                  fetch Ctb390CQ7_E into @cCTXX_CLVL, @cCTXX_ITEM, @cCTXX_CUSTO
               end
               close      Ctb390CQ7_E
               deallocate Ctb390CQ7_E
               
            End
            
            If @IN_CTD = '1' and @IN_CTT = '0' and @IN_CT1 = '1' begin
               declare Ctb390CQ7_F Insensitive cursor for
               Select CTH_CLVL, CT1_NORMAL, CTD_ITEM, CT1_CONTA
                 From CTH### CTH, CTD### CTD, CT1### CT1
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and CT1.CT1_FILIAL = @cFilial_CT1
                  and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CT1.CT1_CLASSE = '2'
                  and CT1.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ7### CQ7
                             Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                               and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                               and CQ7.CQ7_ITEM   = CTD.CTD_ITEM
                               and CQ7.CQ7_CCUSTO = ' '
                               and CQ7.CQ7_CONTA  = CT1.CT1_CONTA
                               and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                               and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                               and CQ7.CQ7_TPSALD = '0'
                               and CQ7.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ7_F
               fetch Ctb390CQ7_F into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_ITEM, @cCTXX_CONTA
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_CUSTO  = ' '
                  
                  select @cTpSaldo = '0'
                  select @cStatus  = '1'
                  select @cSlBase  = 'S'
                  select @cDtLp    = ' '
                  select @cLp      = 'N'
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
 

		          SELECT @fim_CUR = 0                 
                  fetch Ctb390CQ7_F into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_ITEM, @cCTXX_CONTA
               end
               close      Ctb390CQ7_F
               deallocate Ctb390CQ7_F
               
            End
            
            If @IN_CTD = '0' and @IN_CTT = '1' and @IN_CT1 = '1' begin
               declare Ctb390CQ7_G Insensitive cursor for
               Select CTH_CLVL, CT1_NORMAL, CTT_CUSTO, CT1_CONTA
                 From CTH### CTH, CTT### CTT, CT1### CT1
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and CT1.CT1_FILIAL = @cFilial_CT1
                  and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CT1.CT1_CLASSE = '2'
                  and CT1.D_E_L_E_T_ = ' '
                  and CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ7### CQ7
                             Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                               and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                               and CQ7.CQ7_ITEM   = ' '
                               and CQ7.CQ7_CCUSTO = CTT.CTT_CUSTO
                               and CQ7.CQ7_CONTA  = CT1.CT1_CONTA
                               and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                               and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                               and CQ7.CQ7_TPSALD = '0'
                               and CQ7.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ7_G
               fetch Ctb390CQ7_G into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_CUSTO, @cCTXX_CONTA
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  select @cCTXX_ITEM   = ' '
                  
                  select @cTpSaldo = '0'
                  select @cStatus  = '1'
                  select @cSlBase  = 'S'
                  select @cDtLp    = ' '
                  select @cLp      = 'N'
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  
                  SELECT @fim_CUR = 0   
                  fetch Ctb390CQ7_G into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_CUSTO, @cCTXX_CONTA
               end
               close      Ctb390CQ7_G
               deallocate Ctb390CQ7_G
               
            End
            
            If @IN_CTD = '1' and @IN_CTT = '1' and @IN_CT1 = '1' begin
               declare Ctb390CQ7_H Insensitive cursor for
               Select CTH_CLVL, CT1_NORMAL, CTD_ITEM, CTT_CUSTO, CT1_CONTA
                 From CTH### CTH, CTD### CTD, CTT### CTT, CT1### CT1
                Where CTH.CTH_FILIAL = @cFilial_CTH
                  and CTH.CTH_CLVL  between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CTH.CTH_CLASSE = '2'
                  and CTH.D_E_L_E_T_ = ' '
                  and CTD.CTD_FILIAL = @cFilial_CTD
                  and CTD.CTD_ITEM  between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CTD.CTD_CLASSE = '2'
                  and CTD.D_E_L_E_T_ = ' '
                  and CTT.CTT_FILIAL = @cFilial_CTT
                  and CTT.CTT_CUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CTT.CTT_CLASSE = '2'
                  and CTT.D_E_L_E_T_ = ' '
                  and CT1.CT1_FILIAL = @cFilial_CT1
                  and CT1.CT1_CONTA between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CT1.CT1_CLASSE = '2'
                  and CT1.D_E_L_E_T_ = ' '
                  and 0 = ( Select Count(*)
                              From CQ7### CQ7
                             Where CQ7.CQ7_FILIAL = @cFilial_CQ7
                               and CQ7.CQ7_CLVL   = CTH.CTH_CLVL
                               and CQ7.CQ7_ITEM   = CTD.CTD_ITEM
                               and CQ7.CQ7_CCUSTO = CTT.CTT_CUSTO
                               and CQ7.CQ7_CONTA  = CT1.CT1_CONTA
                               and CQ7.CQ7_DATA   = @IN_CV1_DTFIM
                               and CQ7.CQ7_MOEDA  = @IN_CV1_MOEDA
                               and CQ7.CQ7_TPSALD = '0'
                               and CQ7.D_E_L_E_T_ = ' ' )
               for read only
               open Ctb390CQ7_H
               fetch Ctb390CQ7_H into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_ITEM, @cCTXX_CUSTO, @cCTXX_CONTA
               
               while ( @@fetch_status = 0 ) begin
                  
                  select @nCTXX_DEBITO = 0
                  select @nCTXX_CREDIT = 0
                  
                  select @cTpSaldo = '0'
                  select @cStatus  = '1'
                  select @cSlBase  = 'S'
                  select @cDtLp    = ' '
                  select @cLp      = 'N'
                  /* ------------------------------------------------------------
                     Insert no CQ6
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ6###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  /* ------------------------------------------------------------
                     Insert no CQ7
                     ------------------------------------------------------------*/
                  select @iRecno = 0
                  select @iRecno = isnull( max(R_E_C_N_O_), 0 ) from CQ7###
                  
                  If @iRecno is null or @iRecno = 0 select @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ7### ( CQ7_FILIAL,   CQ7_CONTA,    CQ7_CCUSTO,   CQ7_ITEM,     CQ7_CLVL,      CQ7_MOEDA,     CQ7_DATA,      CQ7_TPSALD, CQ7_SLBASE,
                                       CQ7_DTLP,     CQ7_LP,       CQ7_STATUS,   CQ7_DEBITO,   CQ7_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ7, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM,  @cCTXX_CLVL,   @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,         @cStatus,     @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
                  
                  SELECT @fim_CUR = 0   
                  fetch Ctb390CQ7_H into @cCTXX_CLVL, @cCTXX_NORMAL, @cCTXX_ITEM, @cCTXX_CUSTO, @cCTXX_CONTA
               end
               close      Ctb390CQ7_H
               deallocate Ctb390CQ7_H
               
            End
            
         end else begin
            /* ------------------------------------------------------------
               @iRepete = 2
               ------------------------------------------------------------*/
            declare Ctb390CQ7_2 Insensitive cursor for
               select R_E_C_N_O_ , IsNull(CQ7_CONTA,' '), IsNull(CQ7_CCUSTO,' '),
                      IsNull(CQ7_ITEM,' '), IsNull(CQ7_CLVL,' '), CQ7_DEBITO, CQ7_CREDIT
                 from CQ7###
                where CQ7_FILIAL = @cFilial_CQ7
                  and CQ7_CLVL   between @IN_CV1_CTHINI and @IN_CV1_CTHFIM
                  and CQ7_ITEM   between @IN_CV1_CTDINI and @IN_CV1_CTDFIM
                  and CQ7_CCUSTO between @IN_CV1_CTTINI and @IN_CV1_CTTFIM
                  and CQ7_CONTA  between @IN_CV1_CT1INI and @IN_CV1_CT1FIM
                  and CQ7_DATA   = @IN_CV1_DTFIM
                  and CQ7_MOEDA  = @IN_CV1_MOEDA
                  and CQ7_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
            for read only
            open Ctb390CQ7_2
            
            fetch Ctb390CQ7_2 into @iRecno, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL, @nCTXX_DEBITO, @nCTXX_CREDIT
            
            while ( @@fetch_status = 0 ) begin
               
               select @cCTXX_NORMAL = ' '
               If @cCTXX_CONTA != ' ' begin
                  Select @cCTXX_NORMAL = IsNull(CT1_NORMAL, ' ')
                    From CT1###
                   Where CT1_FILIAL = @cFilial_CT1
                     and CT1_CONTA  = @cCTXX_CONTA
                     and CT1_CLASSE = '2'
                     and D_E_L_E_T_ = ' '
               End
               /* ------------------------------------------------------------
                  ATUALIZA DEBITO/CERDITO CQ7 DIA
                  ------------------------------------------------------------*/
               if ( @IN_CT1 = '1' ) begin  --Se tiver conta, verificar a natureza da conta.
                  If @IN_COPERACAO = '1' begin
                     If ( @cCTXX_NORMAL = '1' ) begin
                        If ( @IN_CV1_VALOR < 0 ) begin
                           select @nCTXX_CREDIT = @nCTXX_CREDIT+ Abs( @IN_CV1_VALOR )
                           select @nCTXX_DEBITO = @nCTXX_DEBITO
                        end else begin
                           select @nCTXX_DEBITO = @nCTXX_DEBITO + @IN_CV1_VALOR
                           select @nCTXX_CREDIT = @nCTXX_CREDIT
                        end
      		         end else begin
                        If ( @IN_CV1_VALOR < 0 ) begin
                           select @nCTXX_DEBITO = @nCTXX_DEBITO + Abs(@IN_CV1_VALOR)
                           select @nCTXX_CREDIT = @nCTXX_CREDIT
                        end else begin
                           select @nCTXX_CREDIT = @nCTXX_CREDIT + @IN_CV1_VALOR
                           select @nCTXX_DEBITO = @nCTXX_DEBITO
                        end
                     end
                  end else begin  --Se nao tiver conta no orcamento, considerar como devedor
                     If ( @IN_CV1_VALOR < 0 ) begin
                        select @nCTXX_CREDIT = @nCTXX_CREDIT + Abs( @IN_CV1_VALOR )
                        select @nCTXX_DEBITO = @nCTXX_DEBITO
                     end else begin
                        select @nCTXX_DEBITO = @nCTXX_DEBITO + @IN_CV1_VALOR
                        select @nCTXX_CREDIT = @nCTXX_CREDIT
                     end
                  End
               end
               select @cTpSaldo = '0'
               select @cSlBase  = 'S'
               select @cLp      = 'N'
               select @cDtLp    = ' '
               select @cStatus  = ' '
               /* ------------------------------------------------------------
                  Update no CQ7
                  ------------------------------------------------------------*/
               begin tran
               update CQ7###
                  set CQ7_DEBITO = @nCTXX_DEBITO, CQ7_CREDIT = @nCTXX_CREDIT
                where R_E_C_N_O_ = @iRecno
               commit tran
               /* ------------------------------------------------------------
                  Atualiza CQ6
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0 
               select @nCTXX_CREDIT = 0 
               select @iRecno = 0
               select @iRecno = IsNull(R_E_C_N_O_, 0), @nCTXX_DEBITO = CQ6_DEBITO, @nCTXX_CREDIT = CQ6_CREDIT
                 from CQ6###
                where CQ6_FILIAL = @cFilial_CQ6
                  and CQ6_CLVL   = @cCTXX_CLVL
                  and CQ6_ITEM   = @cCTXX_ITEM
                  and CQ6_CCUSTO = @cCTXX_CUSTO
                  and CQ6_CONTA  = @cCTXX_CONTA
                  and CQ6_DATA   = @IN_CV1_DTFIM
                  and CQ6_MOEDA  = @IN_CV1_MOEDA
                  and CQ6_TPSALD = '0'
                  and D_E_L_E_T_ = ' '
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_CREDIT = @nCTXX_CREDIT+ Abs( @IN_CV1_VALOR )
                     select @nCTXX_DEBITO = @nCTXX_DEBITO
                  end else begin
                     select @nCTXX_DEBITO = @nCTXX_DEBITO + @IN_CV1_VALOR
                     select @nCTXX_CREDIT = @nCTXX_CREDIT
                  end
		         end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_DEBITO = @nCTXX_DEBITO + Abs(@IN_CV1_VALOR)
                     select @nCTXX_CREDIT = @nCTXX_CREDIT
                  end else begin
                     select @nCTXX_CREDIT = @nCTXX_CREDIT + @IN_CV1_VALOR
                     select @nCTXX_DEBITO = @nCTXX_DEBITO
                  end
               end

               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA,    CQ6_CCUSTO,    CQ6_ITEM,    CQ6_CLVL,     CQ6_MOEDA,     CQ6_DATA, CQ6_TPSALD, CQ6_SLBASE,
                                       CQ6_DTLP,     CQ6_LP,      CQ6_STATUS,  CQ6_DEBITO,    CQ6_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ6, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL,   @IN_CV1_MOEDA, @cDataF,   @cTpSaldo,  @cSlBase,
                                       @cDtLp,       @cLp,        @cStatus,    @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end else begin
                  /* ------------------------------------------------------------
                     Update no CQ6
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ6###
                     set CQ6_DEBITO = @nCTXX_DEBITO, CQ6_CREDIT = @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               end
               /* ------------------------------------------------------------
                  Atualiza CQ8
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0 
               select @nCTXX_CREDIT = 0 
               select @iRecno = 0
               select @iRecno = IsNull(R_E_C_N_O_ , 0), @nCTXX_DEBITO = CQ8_DEBITO, @nCTXX_CREDIT = CQ8_CREDIT
                 from CQ8###
                where CQ8_FILIAL = @cFilial_CQ8
                  and CQ8_IDENT  = 'CTH'
                  and CQ8_CODIGO = @cCTXX_CLVL
                  and CQ8_DATA   = @cDataF
                  and CQ8_MOEDA  = @IN_CV1_MOEDA
                  and CQ8_TPSALD = '0'
                  and CQ8_LP     = @cLp
                  and D_E_L_E_T_ = ' '
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_CREDIT = @nCTXX_CREDIT+ Abs( @IN_CV1_VALOR )
                     select @nCTXX_DEBITO = @nCTXX_DEBITO
                  end else begin
                     select @nCTXX_DEBITO = @nCTXX_DEBITO + @IN_CV1_VALOR
                     select @nCTXX_CREDIT = @nCTXX_CREDIT
                  end
		         end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_DEBITO = @nCTXX_DEBITO + Abs(@IN_CV1_VALOR)
                     select @nCTXX_CREDIT = @nCTXX_CREDIT
                  end else begin
                     select @nCTXX_CREDIT = @nCTXX_CREDIT + @IN_CV1_VALOR
                     select @nCTXX_DEBITO = @nCTXX_DEBITO
                  end
               end                  
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = Max(R_E_C_N_O_) from CQ8###
                  select @iRecno = @iRecno + 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO,  CQ8_MOEDA,     CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO,   CQ8_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ8, 'CTH',     @cCTXX_CLVL, @IN_CV1_MOEDA, @cDataF,  @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   @nCTXX_DEBITO,@nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end else begin
                  /* ------------------------------------------------------------
                     Update no CQ8
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ8###
                     set CQ8_DEBITO = @nCTXX_DEBITO, CQ8_CREDIT = @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               end
               /* ------------------------------------------------------------
                  Atualiza CQ9
                  ------------------------------------------------------------*/
               select @nCTXX_DEBITO = 0
               select @nCTXX_CREDIT = 0
               select @iRecno = 0
               select @iRecno = IsNull(R_E_C_N_O_, 0), @nCTXX_DEBITO = CQ9_DEBITO, @nCTXX_CREDIT = CQ9_CREDIT
                 from CQ9###
                where CQ9_FILIAL = @cFilial_CQ9
                  and CQ9_IDENT  = 'CTH'
                  and CQ9_CODIGO = @cCTXX_CLVL
                  and CQ9_DATA   = @IN_CV1_DTFIM
                  and CQ9_MOEDA  = @IN_CV1_MOEDA
                  and CQ9_TPSALD = '0'
                  and CQ9_LP     = @cLp
                  and D_E_L_E_T_ = ' '
               /* ------------------------------------------------------------
                  Verifica se a debito ou credito
                  ------------------------------------------------------------*/
               If ( @cCTXX_NORMAL = '1' ) begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_CREDIT = @nCTXX_CREDIT+ Abs( @IN_CV1_VALOR )
                     select @nCTXX_DEBITO = @nCTXX_DEBITO
                  end else begin
                     select @nCTXX_DEBITO = @nCTXX_DEBITO + @IN_CV1_VALOR
                     select @nCTXX_CREDIT = @nCTXX_CREDIT
                  end
		         end else begin
                  If ( @IN_CV1_VALOR < 0 ) begin
                     select @nCTXX_DEBITO = @nCTXX_DEBITO + Abs(@IN_CV1_VALOR)
                     select @nCTXX_CREDIT = @nCTXX_CREDIT
                  end else begin
                     select @nCTXX_CREDIT = @nCTXX_CREDIT + @IN_CV1_VALOR
                     select @nCTXX_DEBITO = @nCTXX_DEBITO
                  end
               end
               
               If @iRecno is null or @iRecno = 0  begin
                  select @iRecno = Max(R_E_C_N_O_) from CQ9###
                  select @iRecno = @iRecno + 1
                  
                  ##TRATARECNO @iRecno\
                  begin tran
                  Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO,  CQ9_MOEDA,     CQ9_DATA,      CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO,    CQ9_CREDIT,    R_E_C_N_O_ )
                               values( @cFilial_CQ9, 'CTH',     @cCTXX_CLVL, @IN_CV1_MOEDA, @IN_CV1_DTFIM, @cTpSaldo,  @cSlBase,   @cDtLp,   @cLp,   @cStatus,   @nCTXX_DEBITO, @nCTXX_CREDIT, @iRecno )
                  commit tran
                  ##FIMTRATARECNO
               end else begin
                  /* ------------------------------------------------------------
                     Update no CQ9
                     ------------------------------------------------------------*/
                  begin tran
                  update CQ9###
                     set CQ9_DEBITO = @nCTXX_DEBITO, CQ9_CREDIT = @nCTXX_CREDIT
                   where R_E_C_N_O_ = @iRecno
                  commit tran
               end
               
               SELECT @fim_CUR = 0   
               fetch Ctb390CQ7_2 into @iRecno, @cCTXX_CONTA, @cCTXX_CUSTO, @cCTXX_ITEM, @cCTXX_CLVL, @nCTXX_DEBITO, @nCTXX_CREDIT
            end
            close      Ctb390CQ7_2
            deallocate Ctb390CQ7_2
         end
         Select @iRepete = @iRepete + 1
      end
   end
   select @OUT_RESULTADO = '1'
end

