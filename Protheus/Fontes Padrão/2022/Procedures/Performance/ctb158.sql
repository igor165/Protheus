Create Procedure CTB158_##(
   @IN_FILIAL     Char( 'CT7_FILIAL' ),
   @IN_CONTAC     Char( 'CT7_CONTA' ),
   @IN_CUSTOC     Char( 'CT3_CUSTO' ),
   @IN_ITEMC      Char( 'CT4_ITEM' ),
   @IN_CLVLC      Char( 'CTI_CLVL' ),
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
   @OUT_RESULT    Char( 01) OutPut

)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Atualiza os Creditos </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
                           @IN_CONTAC       - Conta Crébito
                           @IN_CUSTOC       - CCusto Crébito
                           @IN_ITEMC        - Item Crébito
                           @IN_CLVLc        - ClVl Credito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DC           - Se 2, grava valor dobrado total digitado
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
    Data        :     29/09/2005
    
-------------------------------------------------------------------------------------- */
declare @cFilial_CT7 Char( 'CT7_FILIAL' )
declare @cFilial_CT3 Char( 'CT3_FILIAL' )
declare @cFilial_CT4 Char( 'CT4_FILIAL' )
declare @cFilial_CT6 Char( 'CT6_FILIAL' )
declare @cFilial_CTC Char( 'CTC_FILIAL' )
declare @cFilial_CTI Char( 'CTI_FILIAL' )
declare @cAux        VarChar( 03 )
declare @cAux1       Char( 01 )
declare @cLp         Char( 'CT7_LP' )
declare @cSlBase     Char( 'CT7_SLBASE' )
declare @cStatus     Char( 'CT7_STATUS' )
declare @iRecno      Integer
declare @nValor      Float
declare @nCredit     Float
declare @nAtuCrd     Float
declare @nAntCrd     Float
declare @nAntDeb     Float
declare @nDig        Float
declare @iRecnoAux   Integer
declare @cDataMax    Char( 08 )
begin
   select @OUT_RESULT = '0'
   select @cAux = 'CT7'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT7 OutPut
   select @cAux = 'CT3'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT3 OutPut
   select @cAux = 'CT4'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT4 OutPut
   select @cAux = 'CT6'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT6 OutPut
   select @cAux = 'CTC'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTC OutPut
   select @cAux = 'CTI'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTI OutPut
   
   select @cDataMax = ' '
   select @cSlBase = 'S'
   select @cStatus = '1'
   select @cLp = 'N'
   If @IN_DTLP != ' ' begin
      select @cLp = 'Z'
   end
   select @iRecno   = 0
   select @iRecnoAux = 0
   select @nCredit   = 0
   select @nAtuCrd   = 0
   select @nAntCrd   = 0
   select @nAntDeb   = 0 
   select @nValor    = Round(@IN_VALOR, 2)
   /* ---------------------------------------------------------------------
      Verifica se a ctaC existe na tabela de saldos CT7
      --------------------------------------------------------------------- */
   If @IN_CONTAC != ' ' begin
      Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CT7###
       Where CT7_FILIAL = @cFilial_CT7
         and CT7_CONTA  = @IN_CONTAC
         and CT7_MOEDA  = @IN_MOEDA
         and CT7_TPSALD = @IN_TPSALDO
         and CT7_DATA   = @IN_DATA
         and D_E_L_E_T_ = ' '
      
      If @iRecno = 0 begin
         Select @cDataMax = IsNull(Max(CT7_DATA), ' ')
          From CT7###
         Where CT7_FILIAL = @cFilial_CT7
           and CT7_CONTA  = @IN_CONTAC
           and CT7_MOEDA  = @IN_MOEDA
           and CT7_TPSALD = @IN_TPSALDO
           and CT7_DATA   < @IN_DATA
           and D_E_L_E_T_ = ' '
         
         Select @iRecnoAux = IsNull(Max(R_E_C_N_O_), 0 )
          From CT7###
         Where CT7_FILIAL = @cFilial_CT7
           and CT7_CONTA  = @IN_CONTAC
           and CT7_MOEDA  = @IN_MOEDA
           and CT7_TPSALD = @IN_TPSALDO
           and CT7_DATA   = @cDataMax
           and D_E_L_E_T_ = ' '
         
         If @iRecnoAux > 0 begin

            -- achou dia anterior : recupero saldos de credito e debito 
            select @nAntCrd = CT7_ATUCRD, @nAntDeb = CT7_ATUDEB
              From CT7###
             Where R_E_C_N_O_ = @iRecnoAux
            
         End
         
         select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CT7###
         select @iRecno = @iRecno + 1
         
         select @nCredit = @nValor
         select @nAtuCrd = Round( @nAntCrd, 2 ) + @nValor
         ##TRATARECNO @iRecno\
         begin tran
			Insert into CT7###( CT7_FILIAL,   CT7_CONTA,  CT7_MOEDA,  CT7_TPSALD,  CT7_DATA, CT7_CREDIT,
                             CT7_ATUCRD,   CT7_ANTCRD, CT7_ATUDEB, CT7_ANTDEB,  CT7_SLBASE, CT7_STATUS, CT7_LP,      R_E_C_N_O_ )
                     Values( @cFilial_CT7, @IN_CONTAC, @IN_MOEDA,  @IN_TPSALDO, @IN_DATA, @nCredit,
                             @nAtuCrd,     @nAntCrd,   @nAntDeb,   @nAntDeb,    @cSlBase,   @cStatus,   @cLp,        @iRecno )
         commit tran                    
        ##FIMTRATARECNO
      end else begin
         /* ---------------------------------------------------------------------
            Se achou efetua um update
            --------------------------------------------------------------------- */
            begin tran
				UpDate CT7###
				Set CT7_CREDIT = CT7_CREDIT + @nValor, CT7_ATUCRD = CT7_ATUCRD + @nValor
				Where R_E_C_N_O_ = @iRecno
			commit tran
      End
   End
   /*---------------------------------------------------------------
     Inicio Atualizacao do CT7 se houver dados posteriores
     --------------------------------------------------------------- */
   Declare CTB_CT7 insensitive cursor for
      select R_E_C_N_O_
        From CT7###
       Where CT7_FILIAL  = @cFilial_CT7
         and CT7_DATA    > @IN_DATA
         and CT7_CONTA   = @IN_CONTAC
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
        set CT7_ATUCRD = CT7_ATUCRD + @nValor, CT7_ANTCRD = CT7_ANTCRD + @nValor
		Where R_E_C_N_O_ = @iRecno
	  commit tran
      
      Fetch CTB_CT7 into @iRecno
   End
   Close CTB_CT7
   Deallocate CTB_CT7
   
   /*---------------------------------------------------------------
     Inicia Atualização do CT3
     --------------------------------------------------------------- */
   If @IN_CUSTOC <> ' ' begin
      select @iRecno    = 0
      select @iRecnoAux = 0
      select @nCredit   = 0
      select @nAtuCrd   = 0
      select @nAntCrd   = 0
      select @nAntDeb   = 0 
      /* ---------------------------------------------------------------------
         Verifica se a ctaC+CustoC existe na tabela de saldos CT3
         --------------------------------------------------------------------- */
      Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CT3###
       Where CT3_FILIAL = @cFilial_CT3
         and CT3_CONTA  = @IN_CONTAC
         and CT3_CUSTO  = @IN_CUSTOC
         and CT3_MOEDA  = @IN_MOEDA
         and CT3_TPSALD = @IN_TPSALDO
         and CT3_DATA   = @IN_DATA
         and D_E_L_E_T_ = ' '
      
      If @iRecno = 0 begin
         Select @cDataMax = IsNull(Max( CT3_DATA ), ' ')
           From CT3###
          Where CT3_FILIAL = @cFilial_CT3
            and CT3_CONTA  = @IN_CONTAC
            and CT3_CUSTO  = @IN_CUSTOC
            and CT3_MOEDA  = @IN_MOEDA
            and CT3_TPSALD = @IN_TPSALDO
            and CT3_DATA   < @IN_DATA
            and D_E_L_E_T_ = ' '
            
         Select @iRecnoAux = IsNull(Max(R_E_C_N_O_), 0)
           From CT3###
          Where CT3_FILIAL = @cFilial_CT3
            and CT3_CONTA  = @IN_CONTAC
            and CT3_CUSTO  = @IN_CUSTOC
            and CT3_MOEDA  = @IN_MOEDA
            and CT3_TPSALD = @IN_TPSALDO
            and CT3_DATA   < @cDataMax
            and D_E_L_E_T_ = ' '
         
         If @iRecnoAux > 0 begin
            select @nAntCrd = CT3_ATUCRD, @nAntDeb = CT3_ATUDEB
              From CT3###
             Where R_E_C_N_O_ = @iRecnoAux
         End
         
         select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CT3###
         select @iRecno = @iRecno + 1
         
         select @nCredit = @nValor
         select @nAtuCrd = Round( @nAntCrd, 2 ) + @nValor
         ##TRATARECNO @iRecno\
         begin tran
			Insert into CT3###( CT3_FILIAL,   CT3_CONTA,  CT3_CUSTO,  CT3_MOEDA,  CT3_TPSALD,  CT3_DATA,
                             CT3_CREDIT,   CT3_ATUCRD, CT3_ANTCRD, CT3_ATUDEB, CT3_ANTDEB, CT3_SLBASE, CT3_STATUS,  CT3_LP,      R_E_C_N_O_ )
                     Values( @cFilial_CT3, @IN_CONTAC, @IN_CUSTOC, @IN_MOEDA,  @IN_TPSALDO, @IN_DATA,
                             @nCredit,     @nAtuCrd ,  @nAntCrd,   @nAntDeb ,  @nAntDeb,   @cSlBase,   @cStatus,    @cLp,        @iRecno )
         commit tran                    
        ##FIMTRATARECNO
      end else begin
         /* ---------------------------------------------------------------------
            Se achou efetua um update
            --------------------------------------------------------------------- */
            begin tran
				UpDate CT3###
				Set CT3_CREDIT = CT3_CREDIT + @nValor, CT3_ATUCRD = CT3_ATUCRD + @nValor
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
           and ( CT3_CONTA  = @IN_CONTAC and CT3_CUSTO = @IN_CUSTOC )
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
            set CT3_ATUCRD = CT3_ATUCRD + @nValor, CT3_ANTCRD = CT3_ANTCRD + @nValor
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
      EXEC CTB161_## @IN_FILIAL, @IN_DATA, @cAux, @IN_CUSTOC, @cAux1, @cAux1, @IN_MOEDA, @IN_TPSALDO, @cLp
   End
   /*---------------------------------------------------------------
     Inicia Atualização do CT4
     --------------------------------------------------------------- */
   If @IN_ITEMC <> ' ' begin
      select @iRecno    = 0
      select @iRecnoAux = 0
      select @nCredit   = 0
      select @nAtuCrd   = 0
      select @nAntCrd   = 0
      select @nAntDeb   = 0
      /* ---------------------------------------------------------------------
         Verifica se a ctaC+CustoC+ItemC existe na tabela de saldos CT4
         --------------------------------------------------------------------- */
      Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CT4###
       Where CT4_FILIAL = @cFilial_CT4
         and CT4_CONTA  = @IN_CONTAC
         and CT4_CUSTO  = @IN_CUSTOC
         and CT4_ITEM   = @IN_ITEMC
         and CT4_MOEDA  = @IN_MOEDA
         and CT4_TPSALD = @IN_TPSALDO
         and CT4_DATA   = @IN_DATA
         and D_E_L_E_T_ = ' '
      
      If @iRecno = 0 begin
         Select @cDataMax = IsNull(Max( CT4_DATA ), ' ')
           From CT4###
          Where CT4_FILIAL = @cFilial_CT4
            and CT4_CONTA  = @IN_CONTAC
            and CT4_CUSTO  = @IN_CUSTOC
            and CT4_ITEM   = @IN_ITEMC
            and CT4_MOEDA  = @IN_MOEDA
            and CT4_TPSALD = @IN_TPSALDO
            and CT4_DATA   < @IN_DATA
            and D_E_L_E_T_ = ' '
         
         Select @iRecnoAux = IsNull(Max( R_E_C_N_O_ ), 0)
           From CT4###
          Where CT4_FILIAL = @cFilial_CT4
            and CT4_CONTA  = @IN_CONTAC
            and CT4_CUSTO  = @IN_CUSTOC
            and CT4_ITEM   = @IN_ITEMC
            and CT4_MOEDA  = @IN_MOEDA
            and CT4_TPSALD = @IN_TPSALDO
            and CT4_DATA   = @cDataMax
            and D_E_L_E_T_ = ' '
         
         If @iRecnoAux > 0 begin
            Select @nAntCrd = CT4_ATUCRD, @nAntDeb = CT4_ATUDEB
             From CT4###
            Where R_E_C_N_O_ = @iRecnoAux
            
         End
         
         select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CT4###
         select @iRecno = @iRecno + 1
         
         select @nCredit = @nValor
         select @nAtuCrd = Round( @nAntCrd, 2 ) + @nValor
         ##TRATARECNO @iRecno\
         begin tran
			Insert into CT4###( CT4_FILIAL,   CT4_CONTA,  CT4_CUSTO,  CT4_ITEM,   CT4_MOEDA, CT4_TPSALD,  CT4_DATA,
                             CT4_CREDIT,   CT4_ATUCRD, CT4_ANTCRD, CT4_ATUDEB, CT4_ANTDEB, CT4_SLBASE, CT4_STATUS,CT4_LP,    R_E_C_N_O_ )
                     Values( @cFilial_CT4, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC,  @IN_MOEDA, @IN_TPSALDO, @IN_DATA,
                             @nCredit,     @nAtuCrd ,  @nAntCrd,   @nAntDeb,   @nAntDeb,  @cSlBase,   @cStatus,   @cLp,      @iRecno )
         commit tran                    
        ##FIMTRATARECNO
      end else begin
         /* ---------------------------------------------------------------------
            Se achou efetua um update
            --------------------------------------------------------------------- */
            begin tran
				UpDate CT4###
				Set CT4_CREDIT = CT4_CREDIT + @nValor, CT4_ATUCRD = CT4_ATUCRD + @nValor
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
           and ( CT4_CONTA  = @IN_CONTAC and CT4_CUSTO = @IN_CUSTOC and CT4_ITEM = @IN_ITEMC )
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
            set CT4_ATUCRD = CT4_ATUCRD + @nValor, CT4_ANTCRD = CT4_ANTCRD + @nValor
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
      EXEC CTB161_## @IN_FILIAL, @IN_DATA, @cAux, @IN_CUSTOC, @IN_ITEMC, @cAux1, @IN_MOEDA, @IN_TPSALDO, @cLp
   End
   /*---------------------------------------------------------------
     Inicia Atualização do CTI
     --------------------------------------------------------------- */
   If @IN_CLVLC <> ' ' begin
      select @iRecno    = 0
      select @iRecnoAux = 0
      select @nCredit   = 0
      select @nAtuCrd   = 0
      select @nAntCrd   = 0
      select @nAntDeb   = 0
      /* ---------------------------------------------------------------------
         Verifica se a ctaC+CustoC+ItemC+clvlC existe na tabela de saldos CTI
         --------------------------------------------------------------------- */
      Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CTI###
       Where CTI_FILIAL = @cFilial_CTI
         and CTI_CONTA  = @IN_CONTAC
         and CTI_CUSTO  = @IN_CUSTOC
         and CTI_ITEM   = @IN_ITEMC
         and CTI_CLVL   = @IN_CLVLC
         and CTI_MOEDA  = @IN_MOEDA
         and CTI_TPSALD = @IN_TPSALDO
         and CTI_DATA   = @IN_DATA
         and D_E_L_E_T_ = ' '
      
      If @iRecno = 0 begin
         Select @cDataMax = IsNull(Max( CTI_DATA ), ' ')
           From CTI###
          Where CTI_FILIAL = @cFilial_CTI
            and CTI_CONTA  = @IN_CONTAC
            and CTI_CUSTO  = @IN_CUSTOC
            and CTI_ITEM   = @IN_ITEMC
            and CTI_CLVL   = @IN_CLVLC
            and CTI_MOEDA  = @IN_MOEDA
            and CTI_TPSALD = @IN_TPSALDO
            and CTI_DATA   < @IN_DATA
            and D_E_L_E_T_ = ' '
         
         Select @iRecnoAux = IsNull(Max( R_E_C_N_O_ ), 0)
           From CTI###
          Where CTI_FILIAL = @cFilial_CTI
            and CTI_CONTA  = @IN_CONTAC
            and CTI_CUSTO  = @IN_CUSTOC
            and CTI_ITEM   = @IN_ITEMC
            and CTI_CLVL   = @IN_CLVLC
            and CTI_MOEDA  = @IN_MOEDA
            and CTI_TPSALD = @IN_TPSALDO
            and CTI_DATA   = @cDataMax
            and D_E_L_E_T_ = ' '
         
         If @iRecnoAux > 0 begin
            Select @nAntCrd = CTI_ATUCRD, @nAntDeb = CTI_ATUDEB
              From CTI###
             Where R_E_C_N_O_ = @iRecnoAux
            
         End
         
         select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CTI###
         select @iRecno = @iRecno + 1
         
         select @nCredit = @nValor
         select @nAtuCrd = Round( @nAntCrd, 2 ) + @nValor
         ##TRATARECNO @iRecno\
         begin tran
			Insert into CTI###( CTI_FILIAL,   CTI_CONTA,  CTI_CUSTO,  CTI_ITEM,   CTI_CLVL,   CTI_MOEDA, CTI_TPSALD,  CTI_DATA,
                             CTI_CREDIT,   CTI_ATUCRD, CTI_ANTCRD, CTI_ATUDEB, CTI_ANTDEB, CTI_SLBASE, CTI_STATUS, CTI_LP,    R_E_C_N_O_ )
                     Values( @cFilial_CTI, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC,  @IN_CLVLC,  @IN_MOEDA, @IN_TPSALDO, @IN_DATA,
                             @nCredit,     @nAtuCrd ,  @nAntCrd,   @nAntDeb,   @nAntDeb,   @cSlBase,   @cStatus,   @cLp,      @iRecno )
         commit tran                    
        ##FIMTRATARECNO
      end else begin
		begin tran
			UpDate CTI###
            Set CTI_CREDIT = CTI_CREDIT + @nValor, CTI_ATUCRD = CTI_ATUCRD + @nValor
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
           and ( CTI_CONTA  = @IN_CONTAC and CTI_CUSTO = @IN_CUSTOC and CTI_ITEM = @IN_ITEMC and CTI_CLVL = @IN_CLVLC )
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
            set CTI_ATUCRD = CTI_ATUCRD + @nValor, CTI_ANTCRD = CTI_ANTCRD + @nValor
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
      EXEC CTB161_## @IN_FILIAL, @IN_DATA, @cAux, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_MOEDA, @IN_TPSALDO, @cLp
   End
   select @OUT_RESULT = '1'
End
