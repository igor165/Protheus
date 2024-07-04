 Create Procedure CTB159_##(
   @IN_FILIAL     Char( 'CT7_FILIAL' ),
   @IN_CONTAD     Char( 'CT7_CONTA' ),
   @IN_CUSTOD     Char( 'CT3_CUSTO' ),
   @IN_ITEMD      Char( 'CT4_ITEM' ),
   @IN_CLVLD      Char( 'CTI_CLVL' ),
   @IN_MOEDA      Char( 'CT7_MOEDA' ),
   @IN_DC         Char( 'CT2_DC' ),
   @IN_DATA       Char( 08 ),
   @IN_TPSALDO    Char( 'CT7_TPSALD' ),
   @IN_DTLP       Char( 08 ),
   @IN_MVSOMA     Char( 01 ),
   @IN_LOTE       Char( 'CT2_LOTE' ),
   @IN_SBLOTE     Char( 'CT2_SBLOTE' ),
   @IN_DOC        Char( 'CT2_DOC' ),
   @IN_VALOR      Float,
   @OUT_RESULT    Char(01) OutPut
)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Faz a chamada da operacao de EXCLUSAO </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTAC       - Conta Crébito
                           @IN_CUSTOD       - CCusto a Débito
                           @IN_CUSTOC       - CCusto Crébito
                           @IN_ITEMD        - Item Débito
                           @IN_ITEMC        - Item Crébito
                           @IN_CLVLD        - ClVl Débito
                           @IN_CLVLC        - ClVl Crébito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_DATA         - Data do Lancto
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_DTLP         - Data de Apuracao de Lp
                           @IN_MVSOMA       - Se 1, soma uma vez, se 2 dua vezes
                           @IN_LOTE         - Nro Lote do Lancto
                           @IN_SBLOTE       - Nro do SubLote 
                           @IN_DOC          - Nro do Documento
                           @IN_VALOR        - Valor Atual
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     20/05/2005
    
-------------------------------------------------------------------------------------- */
declare @cFilial_CT7 Char( 'CT7_FILIAL' )
declare @cFilial_CT3 Char( 'CT3_FILIAL' )
declare @cFilial_CT4 Char( 'CT4_FILIAL' )
declare @cFilial_CTC Char( 'CTC_FILIAL' )
declare @cFilial_CTI Char( 'CTI_FILIAL' )
declare @cAux        VarChar( 03 )
declare @cAux1       Char( 01 )
declare @cLp         Char( 'CT7_LP' )
declare @iRecno      Integer
declare @nValor      Float
declare @cSlComp     Char(01)

begin
   
   select @OUT_RESULT = '0'
   select @cAux = 'CT7'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT7 OutPut
   select @cAux = 'CT3'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT3 OutPut
   select @cAux = 'CT4'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT4 OutPut
   select @cAux = 'CTC'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTC OutPut
   select @cAux = 'CTI'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTI OutPut
   
   select @cLp = 'N'
   If @IN_DTLP != ' ' begin
      select @cLp = 'Z'
   end
   select @cSlComp = 'N'
   select @iRecno   = 0
   select @nValor   = Round(@IN_VALOR, 2)
   /* ---------------------------------------------------------------------
      Verifica se a ctaD existe na tabela de saldos CT7
      --------------------------------------------------------------------- */
   If @IN_CONTAD <> ' ' begin
      Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CT7###
       Where CT7_FILIAL = @cFilial_CT7
         and CT7_CONTA  = @IN_CONTAD
         and CT7_MOEDA  = @IN_MOEDA
         and CT7_TPSALD = @IN_TPSALDO
         and CT7_DATA   = @IN_DATA
         and CT7_LP     = @cLp
         and D_E_L_E_T_ = ' '
      
      If @iRecno > 0 begin
         /* ---------------------------------------------------------------------
             Se achou efetua um update
            --------------------------------------------------------------------- */
          begin tran
			Update CT7###
            Set CT7_DEBITO = CT7_DEBITO - @nValor, CT7_ATUDEB = CT7_ATUDEB - @nValor
			Where R_E_C_N_O_ = @iRecno  
          commit tran        
      End
      /*---------------------------------------------------------------
        Inicio Atualizacao do CT7 se houver dados posteriores
        --------------------------------------------------------------- */
      Declare CTB_CT7 insensitive cursor for
      select R_E_C_N_O_
        From CT7###
       Where CT7_FILIAL  = @cFilial_CT7
         and CT7_DATA    > @IN_DATA
         and CT7_CONTA   = @IN_CONTAD 
         and CT7_TPSALD  = @IN_TPSALDO
         and CT7_MOEDA   = @IN_MOEDA
         and CT7_LP      = @cLp
         and D_E_L_E_T_  = ' '
      For read only
      Open CTB_CT7
      
      Fetch CTB_CT7 into @iRecno
      
      While ( @@Fetch_status = 0 ) begin
         begin tran
			Update CT7###
            set CT7_ATUDEB = CT7_ATUDEB - @nValor, CT7_ANTDEB = CT7_ANTDEB - @nValor
			Where R_E_C_N_O_ = @iRecno
		 commit tran
         
         Fetch CTB_CT7 into @iRecno
      End
      Close CTB_CT7
      Deallocate CTB_CT7 
   End  
   /*---------------------------------------------------------------
     Inicia Atualização do CT3
     --------------------------------------------------------------- */
   If @IN_CUSTOD <> ' ' begin
      select @iRecno    = 0
      /*---------------------------------------------------------------------
        Verifica se a ctaD+CustoD existe na tabela de saldos CT3
      --------------------------------------------------------------------- */
      Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CT3###
       Where CT3_FILIAL = @cFilial_CT3
         and CT3_CONTA  = @IN_CONTAD
         and CT3_CUSTO  = @IN_CUSTOD
         and CT3_MOEDA  = @IN_MOEDA
         and CT3_TPSALD = @IN_TPSALDO
         and CT3_DATA   = @IN_DATA
         and CT3_LP     = @cLp
         and D_E_L_E_T_ = ' '
         
      If @iRecno > 0 begin
         /* ---------------------------------------------------------------------
            Se achou efetua um update
          --------------------------------------------------------------------- */
         begin tran
			Update CT3###
            Set CT3_DEBITO = CT3_DEBITO - @nValor, CT3_ATUDEB = CT3_ATUDEB - @nValor, CT3_SLCOMP = @cSlComp
			Where R_E_C_N_O_ = @iRecno
		 commit tran
		 
      End
      /*---------------------------------------------------------------
        Inicio Atualizacao do CT3 qdo houver dados posteriores
        --------------------------------------------------------------- */      
      Declare CTB_CT3 insensitive cursor for
         select R_E_C_N_O_
           From CT3###
         Where CT3_FILIAL   = @cFilial_CT3
           and CT3_DATA     > @IN_DATA
           and CT3_CONTA    = @IN_CONTAD 
           and CT3_CUSTO    = @IN_CUSTOD  
           and CT3_TPSALD   = @IN_TPSALDO
           and CT3_MOEDA    = @IN_MOEDA
           and CT3_LP       = @cLp
           and D_E_L_E_T_   = ' '
         For read only
         Open CTB_CT3
      Fetch CTB_CT3 into @iRecno
      
      While ( @@Fetch_status = 0 ) begin
         begin tran
			Update CT3###
            set CT3_ATUDEB = CT3_ATUDEB - @nValor, CT3_ANTDEB = CT3_ANTDEB - @nValor, CT3_SLCOMP = @cSlComp
			Where R_E_C_N_O_ = @iRecno
         commit tran
         
         Fetch CTB_CT3 into @iRecno
      End
      Close CTB_CT3
      Deallocate CTB_CT3      
      /*---------------------------------------------------------------
        Inicia Atualização dos saldos flags de slds compostos
        --------------------------------------------------------------- */
      select @cAux = 'CTT'
      select @cAux1 = ' '
      EXEC CTB161_## @IN_FILIAL, @IN_DATA, @cAux, @IN_CUSTOD, @cAux1, @cAux1, @IN_MOEDA, @IN_TPSALDO, @cLp
   End
   /*---------------------------------------------------------------
     Inicia Atualização do CT4
     --------------------------------------------------------------- */
   If @IN_ITEMD <> ' ' begin
      select @iRecno    = 0
      /* ---------------------------------------------------------------------
      Verifica se a ctaD+CustoD+ItemD existe na tabela de saldos CT4
      --------------------------------------------------------------------- */
      Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CT4###
       Where CT4_FILIAL = @cFilial_CT4
         and CT4_CONTA  = @IN_CONTAD
         and CT4_CUSTO  = @IN_CUSTOD
         and CT4_ITEM   = @IN_ITEMD
         and CT4_MOEDA  = @IN_MOEDA
         and CT4_TPSALD = @IN_TPSALDO 
         and CT4_DATA   = @IN_DATA
         and CT4_LP     = @cLp
         and D_E_L_E_T_ = ' '
       
      If @iRecno > 0 begin
         /* ---------------------------------------------------------------------
            Se achou efetua um update
         --------------------------------------------------------------------- */
         begin tran
			Update CT4###
            Set CT4_DEBITO = CT4_DEBITO - @nValor, CT4_ATUDEB = CT4_ATUDEB - @nValor, CT4_SLCOMP = @cSlComp
			Where R_E_C_N_O_ = @iRecno
		 commit tran	
      End
      /*---------------------------------------------------------------
        Inicio Atualizacao do CT4 qdo houver dados posteriores
        --------------------------------------------------------------- */      
      Declare CTB_CT4 insensitive cursor for
         select R_E_C_N_O_
           From CT4###
         Where CT4_FILIAL   = @cFilial_CT4
           and CT4_DATA     > @IN_DATA
           and CT4_CONTA    = @IN_CONTAD
           and CT4_CUSTO    = @IN_CUSTOD
           and CT4_ITEM     = @IN_ITEMD 
           and CT4_TPSALD   = @IN_TPSALDO
           and CT4_MOEDA    = @IN_MOEDA
           and CT4_LP       = @cLp
           and D_E_L_E_T_   = ' '
         For read only
         Open CTB_CT4
      Fetch CTB_CT4 into @iRecno
      
      While ( @@Fetch_status = 0 ) begin
         begin tran
			Update CT4###
            set CT4_ATUDEB = CT4_ATUDEB - @nValor, CT4_ANTDEB = CT4_ANTDEB - @nValor, CT4_SLCOMP = @cSlComp
			Where R_E_C_N_O_ = @iRecno
		 commit tran
         
         Fetch CTB_CT4 into @iRecno
      End
      Close CTB_CT4
      Deallocate CTB_CT4
      /*---------------------------------------------------------------
        Inicia Atualização dos saldos flags de slds compostos
        --------------------------------------------------------------- */
      select @cAux = 'CTD'
      select @cAux1 = ' '
      EXEC CTB161_## @IN_FILIAL, @IN_DATA, @cAux, @IN_CUSTOD, @IN_ITEMD, @cAux1, @IN_MOEDA, @IN_TPSALDO, @cLp
   End
   /*---------------------------------------------------------------
     Inicia Atualização do CTI
     --------------------------------------------------------------- */
   If @IN_CLVLD <> ' ' begin
      select @iRecno    = 0
      /* ---------------------------------------------------------------------
       Verifica se a ctaD+CustoD+ItemD+ClvlD existe na tabela de saldos CTI
      --------------------------------------------------------------------- */
      Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CTI###
       Where CTI_FILIAL = @cFilial_CTI
         and CTI_CONTA  = @IN_CONTAD
         and CTI_CUSTO  = @IN_CUSTOD
         and CTI_ITEM   = @IN_ITEMD
         and CTI_CLVL   = @IN_CLVLD
         and CTI_MOEDA  = @IN_MOEDA
         and CTI_TPSALD = @IN_TPSALDO
         and CTI_DATA   = @IN_DATA
         and CTI_LP     = @cLp
         and D_E_L_E_T_ = ' '
      
      If @iRecno > 0 begin
        /* ---------------------------------------------------------------------
         Se achou efetua um update
        --------------------------------------------------------------------- */           
         begin tran
			Update CTI###
            Set CTI_DEBITO = CTI_DEBITO - @nValor, CTI_ATUDEB = CTI_ATUDEB - @nValor, CTI_SLCOMP = @cSlComp
			Where R_E_C_N_O_ = @iRecno
		 commit tran
      End
      /*---------------------------------------------------------------
        Inicio Atualizacao do CTI qdo houver dados posteriores
        --------------------------------------------------------------- */      
      Declare CTB_CTI insensitive cursor for
         select R_E_C_N_O_
           From CTI###
         Where CTI_FILIAL   = @cFilial_CTI
           and CTI_DATA     > @IN_DATA
           and CTI_CONTA    = @IN_CONTAD
           and CTI_CUSTO    = @IN_CUSTOD
           and CTI_ITEM     = @IN_ITEMD 
           and CTI_CLVL     = @IN_CLVLD 
           and CTI_TPSALD   = @IN_TPSALDO
           and CTI_MOEDA    = @IN_MOEDA
           and CTI_LP       = @cLp
           and D_E_L_E_T_   = ' '
         For read only
         Open CTB_CTI
      Fetch CTB_CTI into @iRecno
      
      While ( @@Fetch_status = 0 ) begin
         begin tran
			Update CTI###
            set CTI_ATUDEB = CTI_ATUDEB - @nValor, CTI_ANTDEB = CTI_ANTDEB - @nValor, CTI_SLCOMP = @cSlComp
			Where R_E_C_N_O_ = @iRecno
		 commit tran
                  
         Fetch CTB_CTI into @iRecno
      End
      Close CTB_CTI
      Deallocate CTB_CTI
      /*---------------------------------------------------------------
        Inicia Atualização dos saldos flags de slds compostos
        --------------------------------------------------------------- */
      select @cAux = 'CTH'
      EXEC CTB161_## @IN_FILIAL, @IN_DATA, @cAux, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_MOEDA, @IN_TPSALDO, @cLp
   End
   select @OUT_RESULT = '1'
End
