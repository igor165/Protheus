Create Procedure CTB182_##(
   @IN_FILIAL     Char( 'CQ0_FILIAL' ),
   @IN_OPER       Char( 01 ),
   @IN_DC         Char( 01 ),
   @IN_CONTAD     Char( 'CQ0_CONTA' ),
   @IN_CONTAC     Char( 'CQ0_CONTA' ),
   @IN_CUSTOD     Char( 'CQ2_CCUSTO' ),
   @IN_CUSTOC     Char( 'CQ2_CCUSTO' ),
   @IN_ITEMD      Char( 'CQ4_ITEM' ),
   @IN_ITEMC      Char( 'CQ4_ITEM' ),
   @IN_MOEDA      Char( 'CQ0_MOEDA' ),
   @IN_DATA       Char( 08 ),
   @IN_TPSALDO    Char( 'CQ0_TPSALD' ),
   @IN_DTLP       Char( 08 ),
   @IN_VALOR      Float,
   @IN_INTEGRIDADE   Char( 01 ),
   @OUT_RESULT    Char( 01 ) OutPut

)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Atualiza Débito</d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
      						   @IN_OPE          - Operacao Aritmética ( '+' = Somar '-' = Subtrair )
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTAC       - Conta a Crédito
                           @IN_CUSTOD       - C.Custo a Débito
                           @IN_CUSTOC       - C.Custo a Crédito
                           @IN_ITEMD        - Item  a Débito
                           @IN_ITEMC        - Item a Crédito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DATA         - Data do Lancto
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_DTLP         - Data de Apuracao de Lp
                           @IN_VALOR        - Valor Atual
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.   </ri>
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     229/09/2005
    
-------------------------------------------------------------------------------------- */
declare @cLp         Char( 'CQ0_LP' )
declare @cSlBase     Char( 'CQ0_SLBASE' )
declare @cStatus     Char( 'CQ0_STATUS' )
declare @iRecno      Integer
declare @nValor      Float
declare @nDebito     Float
declare @nCredit     Float
declare @cDataF      Char( 08 )

begin

    select @OUT_RESULT = '0'
    select @nValor    = Round(@IN_VALOR, 2)
    /* ------------------------------------------------------------- 
        Se for negativo, multiplico por -1
        ------------------------------------------------------------- */
    If @IN_OPER = '-' begin
        select @nValor = Round(@IN_VALOR * (-1), 2)
    End
    /* ------------------------------------------------------------- 
        Marcacao de saldo base e Status
        ------------------------------------------------------------- */
    select @cSlBase = 'S'
    select @cStatus = '1'
    /* ------------------------------------------------------------- 
        Ultimo dia do MES para o saldo do Mes
        ------------------------------------------------------------- */
    Exec LASTDAY_## @IN_DATA, @cDataF OutPut
    /*-----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ5 DIA - Saldo por CONTA + CCUSTO + ITEM
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_ITEMD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ5
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaD+CustoD+ItemD existe na tabela de saldos CQ5
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ5###
        Where CQ5_FILIAL = @IN_FILIAL
            and CQ5_CONTA  = @IN_CONTAD
            and CQ5_CCUSTO = @IN_CUSTOD
            and CQ5_ITEM   = @IN_ITEMD
            and CQ5_MOEDA  = @IN_MOEDA
            and CQ5_TPSALD = @IN_TPSALDO
            and CQ5_DATA   = @IN_DATA
            and CQ5_LP   = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
         
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ5###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ5###( CQ5_FILIAL, CQ5_CONTA,  CQ5_CCUSTO, CQ5_ITEM,   CQ5_MOEDA, CQ5_TPSALD,  CQ5_DATA, CQ5_DEBITO, CQ5_SLBASE, CQ5_STATUS, CQ5_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD,  @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ5###
        Set CQ5_DEBITO = CQ5_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao CREDITO NA TABELA CQ5 DIA - Saldo por CONTA + CCUSTO + ITEM
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_ITEMC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
      
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------
            Inicia Atualização do CQ5
            --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaC+CustoC+ItemC existe na tabela de saldos CQ5
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ5###
        Where CQ5_FILIAL = @IN_FILIAL
            and CQ5_CONTA  = @IN_CONTAC
            and CQ5_CCUSTO = @IN_CUSTOC
            and CQ5_ITEM   = @IN_ITEMC
            and CQ5_MOEDA  = @IN_MOEDA
            and CQ5_TPSALD = @IN_TPSALDO
            and CQ5_DATA   = @IN_DATA
            and CQ5_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ5###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ5###( CQ5_FILIAL, CQ5_CONTA,  CQ5_CCUSTO, CQ5_ITEM,  CQ5_MOEDA, CQ5_TPSALD,  CQ5_DATA, CQ5_CREDIT, CQ5_SLBASE, CQ5_STATUS, CQ5_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ5###
        Set CQ5_CREDIT = CQ5_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ5 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ5###
            Set D_E_L_E_T_ = '*'
        Where CQ5_FILIAL  = @IN_FILIAL
            and Round(CQ5_DEBITO, 2) = 0.00
            and Round(CQ5_CREDIT, 2) = 0.00
            and CQ5_DATA     = @IN_DATA
            and  ((CQ5_CONTA = @IN_CONTAC AND CQ5_CCUSTO = @IN_CUSTOC AND CQ5_ITEM = @IN_ITEMC) 
            or (CQ5_CONTA = @IN_CONTAD AND CQ5_CCUSTO = @IN_CUSTOD AND CQ5_ITEM = @IN_ITEMD))
            and CQ5_TPSALD   = @IN_TPSALDO
            and CQ5_MOEDA    = @IN_MOEDA
            and CQ5_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
      
        begin tran
        delete from CQ5###
    Where CQ5_FILIAL  = @IN_FILIAL
        and Round(CQ5_DEBITO, 2) = 0.00
        and Round(CQ5_CREDIT, 2) = 0.00
   	    and CQ5_DATA    = @IN_DATA
   	    and  ((CQ5_CONTA = @IN_CONTAC AND CQ5_CCUSTO = @IN_CUSTOC AND CQ5_ITEM = @IN_ITEMC) 
            or (CQ5_CONTA = @IN_CONTAD AND CQ5_CCUSTO = @IN_CUSTOD AND CQ5_ITEM = @IN_ITEMD))
   	    and CQ5_TPSALD   = @IN_TPSALDO
   	    and CQ5_MOEDA    = @IN_MOEDA
   	    and CQ5_LP       = @cLp
   	    and D_E_L_E_T_   = '*'
   	    commit tran
    end else begin
        begin tran
        delete from CQ5###
        Where CQ5_FILIAL  = @IN_FILIAL
            and Round(CQ5_DEBITO, 2) = 0.00
            and Round(CQ5_CREDIT, 2) = 0.00
            and CQ5_DATA     = @IN_DATA
            and ((CQ5_CONTA  = @IN_CONTAC AND CQ5_CCUSTO = @IN_CUSTOC AND CQ5_ITEM = @IN_ITEMC) 
            or (CQ5_CONTA = @IN_CONTAD AND CQ5_CCUSTO = @IN_CUSTOD AND CQ5_ITEM = @IN_ITEMD))
            and CQ5_TPSALD   = @IN_TPSALDO
            and CQ5_MOEDA    = @IN_MOEDA
            and CQ5_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
    end
    /* ---------------------------------------------------------------------
        Fim da atualização na tabela CQ5 - Saldo por Conta+Ccusto+Item DIA
        --------------------------------------------------------------------- */  
    /*-----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ4 MES - Saldo por CONTA + CCUSTO + ITEM
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_ITEMD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ4
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaD+CustoD+ItemD existe na tabela de saldos CQ4
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ4###
        Where CQ4_FILIAL = @IN_FILIAL
            and CQ4_CONTA  = @IN_CONTAD
            and CQ4_CCUSTO = @IN_CUSTOD
            and CQ4_ITEM   = @IN_ITEMD
            and CQ4_MOEDA  = @IN_MOEDA
            and CQ4_TPSALD = @IN_TPSALDO
            and CQ4_DATA   = @cDataF
            and CQ4_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
         
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ4###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ4###( CQ4_FILIAL, CQ4_CONTA,  CQ4_CCUSTO, CQ4_ITEM,   CQ4_MOEDA, CQ4_TPSALD,  CQ4_DATA, CQ4_DEBITO, CQ4_SLBASE, CQ4_STATUS, CQ4_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD,  @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ4###
        Set CQ4_DEBITO = CQ4_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao CREDITONA TABELA CQ5 DIA - Saldo por CONTA + CCUSTO + ITEM
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_ITEMC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
      
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------
            Inicia Atualização do CQ4
            --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaC+CustoC+ItemC existe na tabela de saldos CQ4
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ4###
        Where CQ4_FILIAL = @IN_FILIAL
            and CQ4_CONTA  = @IN_CONTAC
            and CQ4_CCUSTO  = @IN_CUSTOC
            and CQ4_ITEM   = @IN_ITEMC
            and CQ4_MOEDA  = @IN_MOEDA
            and CQ4_TPSALD = @IN_TPSALDO
            and CQ4_DATA   = @cDataF
            and CQ4_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ4###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ4###( CQ4_FILIAL, CQ4_CONTA,  CQ4_CCUSTO, CQ4_ITEM,  CQ4_MOEDA, CQ4_TPSALD,  CQ4_DATA, CQ4_CREDIT, CQ4_SLBASE, CQ4_STATUS, CQ4_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ4###
        Set CQ4_CREDIT = CQ4_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ4 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ4###
            Set D_E_L_E_T_ = '*'
        Where CQ4_FILIAL  = @IN_FILIAL
            and Round(CQ4_DEBITO, 2) = 0.00
            and Round(CQ4_CREDIT, 2) = 0.00
            and CQ4_DATA     = @cDataF
            and  ((CQ4_CONTA = @IN_CONTAC AND CQ4_CCUSTO = @IN_CUSTOC AND CQ4_ITEM = @IN_ITEMC) 
            or (CQ4_CONTA = @IN_CONTAD AND CQ4_CCUSTO = @IN_CUSTOD AND CQ4_ITEM = @IN_ITEMD))
            and CQ4_TPSALD   = @IN_TPSALDO
            and CQ4_MOEDA    = @IN_MOEDA
            and CQ4_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
      
        begin tran
        delete from CQ4###
    Where CQ4_FILIAL  = @IN_FILIAL
        and Round(CQ4_DEBITO, 2) = 0.00
        and Round(CQ4_CREDIT, 2) = 0.00
   	    and CQ4_DATA    = @cDataF
   	    and  ((CQ4_CONTA = @IN_CONTAC AND CQ4_CCUSTO = @IN_CUSTOC AND CQ4_ITEM = @IN_ITEMC) 
            or (CQ4_CONTA = @IN_CONTAD AND CQ4_CCUSTO = @IN_CUSTOD AND CQ4_ITEM = @IN_ITEMD))
   	    and CQ4_TPSALD   = @IN_TPSALDO
   	    and CQ4_MOEDA    = @IN_MOEDA
   	    and CQ4_LP       = @cLp
   	    and D_E_L_E_T_   = '*'
   	    commit tran
    end else begin
        begin tran
        delete from CQ4###
        Where CQ4_FILIAL  = @IN_FILIAL
            and Round(CQ4_DEBITO, 2) = 0.00
            and Round(CQ4_CREDIT, 2) = 0.00
            and CQ4_DATA     = @cDataF
            and ((CQ4_CONTA  = @IN_CONTAC AND CQ4_CCUSTO = @IN_CUSTOC AND CQ4_ITEM = @IN_ITEMC) 
            or (CQ4_CONTA = @IN_CONTAD AND CQ4_CCUSTO = @IN_CUSTOD AND CQ4_ITEM = @IN_ITEMD))
            and CQ4_TPSALD   = @IN_TPSALDO
            and CQ4_MOEDA    = @IN_MOEDA
            and CQ4_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
    end
    /* ---------------------------------------------------------------------
        Fim da atualização na tabela CQ4 - Saldo por Conta+Ccusto+Item MES
        --------------------------------------------------------------------- */   
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ9 DIA - SALDO POR ENTIDADE ITEM
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_ITEMD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        /*---------------------------------------------------------------
        Inicio Atualizacao Debito na tabela CQ9 - SALDO POR ENTIDADE CC
        --------------------------------------------------------------- */
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ9
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a CustoD existe na tabela de saldos CQ9 MENSAL
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ9###
        Where CQ9_FILIAL = @IN_FILIAL
            and CQ9_IDENT  = 'CTD'
            and CQ9_CODIGO = @IN_ITEMD
            and CQ9_MOEDA  = @IN_MOEDA
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_DATA   = @IN_DATA
            and CQ9_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ9###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO \@iRecno
            begin tran
            Insert into CQ9###( CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_TPSALD,  CQ9_DATA, CQ9_DEBITO, CQ9_SLBASE, CQ9_STATUS, CQ9_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CTD',     @IN_ITEMD,  @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0, @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ9###
        Set CQ9_DEBITO = CQ9_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /*----------------------------------------------------------------------
        Inicio Atualizacao CREDITO NA TABELA CQ9 - Saldo por ENTIDADE ITEM DIA
        ---------------------------------------------------------------------- */
    If @IN_ITEMC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ9
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaC+CustoC existe na tabela de saldos CQ9
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ9###
        Where CQ9_FILIAL = @IN_FILIAL
            and CQ9_IDENT  = 'CTD'
            and CQ9_CODIGO = @IN_ITEMC
            and CQ9_MOEDA  = @IN_MOEDA
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_DATA   = @IN_DATA
            and CQ9_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ9###
            select @iRecno = @iRecno + 1
           
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ9###( CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_TPSALD,  CQ9_DATA, CQ9_CREDIT, CQ9_SLBASE, CQ9_STATUS, CQ9_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CTD',     @IN_ITEMC,  @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ9###
        Set CQ9_CREDIT = CQ9_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ9 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ9###
            Set D_E_L_E_T_   = '*'
        Where CQ9_FILIAL   = @IN_FILIAL
            and Round(CQ9_DEBITO, 2) = 0.00
            and Round(CQ9_CREDIT, 2) = 0.00
   	    and CQ9_DATA     = @IN_DATA
            and ((CQ9_IDENT  = 'CTD' AND CQ9_CODIGO = @IN_ITEMC) or (CQ9_IDENT  = 'CTD' AND CQ9_CODIGO = @IN_ITEMD))
            and CQ9_TPSALD   = @IN_TPSALDO
            and CQ9_MOEDA    = @IN_MOEDA
            and CQ9_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
        begin tran
        delete from CQ9###
    Where CQ9_FILIAL   = @IN_FILIAL
        and Round(CQ9_DEBITO, 2) = 0.00
        and Round(CQ9_CREDIT, 2) = 0.00
        and CQ9_DATA     = @IN_DATA
        and ((CQ9_IDENT  = 'CTD' AND CQ9_CODIGO = @IN_ITEMC) or (CQ9_IDENT  = 'CTD' AND CQ9_CODIGO = @IN_ITEMD))
        and CQ9_TPSALD   = @IN_TPSALDO
        and CQ9_MOEDA    = @IN_MOEDA
        and CQ9_LP       = @cLp
        and D_E_L_E_T_   = '*'
        commit tran
    end else begin
        begin tran
        delete from CQ9###
    Where CQ9_FILIAL  = @IN_FILIAL
        and Round(CQ9_DEBITO, 2) = 0.00
        and Round(CQ9_CREDIT, 2) = 0.00
   	    and CQ9_DATA     = @IN_DATA
   	    and ((CQ9_IDENT  = 'CTD' AND CQ9_CODIGO = @IN_ITEMC) or (CQ9_IDENT  = 'CTD' AND CQ9_CODIGO = @IN_ITEMD))
   	    and CQ9_TPSALD   = @IN_TPSALDO
   	    and CQ9_MOEDA    = @IN_MOEDA
   	    and CQ9_LP       = @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
    End
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ8 MES - Saldo por ENTIDADE ITEM
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_ITEMD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        /*---------------------------------------------------------------
        Inicio Atualizacao Debito na tabela CQ8 - Saldo por CCUSTO
        --------------------------------------------------------------- */
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ8
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se CustoD existe na tabela de saldos CQ8 MENSAL
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ8###
        Where CQ8_FILIAL = @IN_FILIAL
            and CQ8_IDENT  = 'CTD'
            and CQ8_CODIGO = @IN_ITEMD
            and CQ8_MOEDA  = @IN_MOEDA
            and CQ8_TPSALD = @IN_TPSALDO
            and CQ8_DATA   = @cDataF
            and CQ8_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ8###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO \@iRecno
            begin tran
            Insert into CQ8###( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_TPSALD,  CQ8_DATA, CQ8_DEBITO, CQ8_SLBASE, CQ8_STATUS, CQ8_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CTD',     @IN_ITEMD,   @IN_MOEDA, @IN_TPSALDO, @cDataF,          0, @cSlBase,    @cStatus,  @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ8###
        Set CQ8_DEBITO = CQ8_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /*----------------------------------------------------------------------
        Inicio Atualizacao CREDITO NA TABELA CQ8 - Saldo por ENTIDADE MES
        ---------------------------------------------------------------------- */
    If @IN_ITEMC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ8
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a CustoC existe na tabela de saldos CQ8
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ8###
        Where CQ8_FILIAL = @IN_FILIAL
            and CQ8_IDENT  = 'CTD'
            and CQ8_CODIGO = @IN_ITEMC
            and CQ8_MOEDA  = @IN_MOEDA
            and CQ8_TPSALD = @IN_TPSALDO
            and CQ8_DATA   = @cDataF
            and CQ8_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ8###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ8###( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_TPSALD,  CQ8_DATA, CQ8_CREDIT, CQ8_SLBASE, CQ8_STATUS, CQ8_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CTD',     @IN_ITEMC,  @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ8###
        Set CQ8_CREDIT = CQ8_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ8 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ8###
            Set D_E_L_E_T_   = '*'
        Where CQ8_FILIAL   = @IN_FILIAL
            and Round(CQ8_DEBITO, 2) = 0.00
            and Round(CQ8_CREDIT, 2) = 0.00
   	    and CQ8_DATA     = @cDataF
            and ((CQ8_IDENT  = 'CTD' AND CQ8_CODIGO = @IN_ITEMC) or (CQ8_IDENT  = 'CTD' AND CQ8_CODIGO = @IN_ITEMD))
            and CQ8_TPSALD   = @IN_TPSALDO
            and CQ8_MOEDA    = @IN_MOEDA
            and CQ8_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
        begin tran
        delete from CQ8###
    Where CQ8_FILIAL   = @IN_FILIAL
        and Round(CQ8_DEBITO, 2) = 0.00
        and Round(CQ8_CREDIT, 2) = 0.00
        and CQ8_DATA     = @cDataF
        and ((CQ8_IDENT  = 'CTD' AND CQ8_CODIGO = @IN_ITEMC) or (CQ8_IDENT  = 'CTD' AND CQ8_CODIGO = @IN_ITEMD))
        and CQ8_TPSALD   = @IN_TPSALDO
        and CQ8_MOEDA    = @IN_MOEDA
        and CQ8_LP       = @cLp
        and D_E_L_E_T_   = '*'
        commit tran
    end else begin
        begin tran
        delete from CQ8###
    Where CQ8_FILIAL  = @IN_FILIAL
        and Round(CQ8_DEBITO, 2) = 0.00
        and Round(CQ8_CREDIT, 2) = 0.00
   	    and CQ8_DATA     = @cDataF
   	    and ((CQ8_IDENT  = 'CTD' AND CQ8_CODIGO = @IN_ITEMC) or (CQ8_IDENT  = 'CTD' AND CQ8_CODIGO = @IN_ITEMD))
   	    and CQ8_TPSALD   = @IN_TPSALDO
   	    and CQ8_MOEDA    = @IN_MOEDA
   	    and CQ8_LP       = @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
    End
    select @OUT_RESULT = '1' 
End
