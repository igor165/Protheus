Create Procedure CTB181_##(
   @IN_FILIAL     Char( 'CQ0_FILIAL' ),
   @IN_OPER       Char( 01 ),
   @IN_DC         Char( 01 ),
   @IN_CONTAD     Char( 'CQ0_CONTA' ),
   @IN_CONTAC     Char( 'CQ0_CONTA' ),
   @IN_CUSTOD     Char( 'CQ2_CCUSTO' ),
   @IN_CUSTOC     Char( 'CQ2_CCUSTO' ),
   @IN_MOEDA      Char( 'CQ0_MOEDA' ),
   @IN_DATA       Char( 08 ),
   @IN_TPSALDO    Char( 'CQ0_TPSALD' ),
   @IN_DTLP       Char( 08 ),
   @IN_VALOR      Float,
   @IN_INTEGRIDADE Char( 01 ),
   @OUT_RESULT    Char( 01 ) OutPut

)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Atualiza Saldos no CQ2 </d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
   						   @IN_OPER         - Operacao Aritmética ( '+' = Somar '-' = Subtrair )
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTAC       - Conta a Crédito
                           @IN_CUSTOD       - Centro de Custo a Debito a Atualizar
                           @IN_CUSTOC       - Centro de custo a Credito a Atualizar
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DATA         - Data do Lancto
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_DTLP         - Data de Apuracao de Lp
                           @IN_VALOR        - Valor Atual
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.   </ri>
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Data        :     19/10/2009
    
-------------------------------------------------------------------------------------- */
declare @cLp         Char( 'CQ0_LP' )
declare @cSlBase     Char( 'CQ0_SLBASE' )
declare @cStatus     Char( 'CQ0_STATUS' )
declare @iRecno      Integer
declare @nValor      Float
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
        Inicio Atualizacao DEBITO NA TABELA CQ3 DIA - Saldo por CONTA + CCUSTO
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_CUSTOD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        /*---------------------------------------------------------------
        Inicio Atualizacao Debito na tabela CQ3 - Saldo por CC+Conta
        --------------------------------------------------------------- */
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ3
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaD+CustoD existe na tabela de saldos CQ3 MENSAL
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ3###
        Where CQ3_FILIAL = @IN_FILIAL
            and CQ3_CONTA  = @IN_CONTAD
            and CQ3_CCUSTO = @IN_CUSTOD
            and CQ3_MOEDA  = @IN_MOEDA
            and CQ3_TPSALD = @IN_TPSALDO
            and CQ3_DATA   = @IN_DATA
            and CQ3_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ3###
            select @iRecno = @iRecno + 1
                     
            ##TRATARECNO \@iRecno
            begin tran
            Insert into CQ3###( CQ3_FILIAL, CQ3_CONTA,  CQ3_CCUSTO, CQ3_MOEDA, CQ3_TPSALD,  CQ3_DATA, CQ3_DEBITO, CQ3_SLBASE, CQ3_STATUS, CQ3_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,    @cStatus,  @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ3###
        Set CQ3_DEBITO = CQ3_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /*----------------------------------------------------------------------
        Inicio Atualizacao CREDITO NA TABELA CQ3 - Saldo por C.CUSTO+CONTA DIA
        ---------------------------------------------------------------------- */
    If @IN_CUSTOC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
      
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------
           Inicia Atualização do CQ3
           Verifica se a ctaC+CustoC existe na tabela de saldos CQ3
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ3###
        Where CQ3_FILIAL = @IN_FILIAL
            and CQ3_CONTA  = @IN_CONTAC
            and CQ3_CCUSTO = @IN_CUSTOC
            and CQ3_MOEDA  = @IN_MOEDA
            and CQ3_TPSALD = @IN_TPSALDO
            and CQ3_DATA   = @IN_DATA
            and CQ3_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ3###
            select @iRecno = @iRecno + 1
        
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ3###( CQ3_FILIAL, CQ3_CONTA,  CQ3_CCUSTO, CQ3_MOEDA, CQ3_TPSALD,  CQ3_DATA, CQ3_CREDIT, CQ3_SLBASE, CQ3_STATUS, CQ3_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ3###
        Set CQ3_CREDIT = CQ3_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ3 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ3###
            Set D_E_L_E_T_   = '*'
        Where CQ3_FILIAL   = @IN_FILIAL
            and Round(CQ3_DEBITO, 2) = 0.00
            and Round(CQ3_CREDIT, 2) = 0.00
   	    and CQ3_DATA     = @IN_DATA
            and ((CQ3_CONTA  = @IN_CONTAC AND CQ3_CCUSTO = @IN_CUSTOC) or (CQ3_CONTA  = @IN_CONTAD AND CQ3_CCUSTO = @IN_CUSTOD))
            and CQ3_TPSALD   = @IN_TPSALDO
            and CQ3_MOEDA    = @IN_MOEDA
            and CQ3_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
        begin tran
        delete from CQ3###
    Where CQ3_FILIAL   = @IN_FILIAL
        and Round(CQ3_DEBITO, 2) = 0.00
        and Round(CQ3_CREDIT, 2) = 0.00
        and CQ3_DATA     = @IN_DATA
        and ((CQ3_CONTA  = @IN_CONTAC AND CQ3_CCUSTO = @IN_CUSTOC) or (CQ3_CONTA  = @IN_CONTAD AND CQ3_CCUSTO = @IN_CUSTOD))
        and CQ3_TPSALD   = @IN_TPSALDO
        and CQ3_MOEDA    = @IN_MOEDA
        and CQ3_LP       =  @cLp
        and D_E_L_E_T_   = '*'
        commit tran
    end else begin
        begin tran
        delete from CQ3###
    Where CQ3_FILIAL  = @IN_FILIAL
        and Round(CQ3_DEBITO, 2) = 0.00
        and Round(CQ3_CREDIT, 2) = 0.00
   	    and CQ3_DATA     = @IN_DATA
   	    and ((CQ3_CONTA  = @IN_CONTAC AND CQ3_CCUSTO = @IN_CUSTOC) or (CQ3_CONTA  = @IN_CONTAD AND CQ3_CCUSTO = @IN_CUSTOD))
   	    and CQ3_TPSALD   = @IN_TPSALDO
   	    and CQ3_MOEDA    = @IN_MOEDA
   	    and CQ3_LP       = @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
    End
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ2 MES - Saldo por CONTA + CCUSTO
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_CUSTOD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        /*---------------------------------------------------------------
        Inicio Atualizacao Debito na tabela CQ2 - Saldo por CC+Conta
        --------------------------------------------------------------- */
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
            Inicia Atualização do CQ2
            Verifica se a ctaD+CustoD existe na tabela de saldos CQ2 MENSAL
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ2###
        Where CQ2_FILIAL = @IN_FILIAL
            and CQ2_CONTA  = @IN_CONTAD
            and CQ2_CCUSTO = @IN_CUSTOD
            and CQ2_MOEDA  = @IN_MOEDA
            and CQ2_TPSALD = @IN_TPSALDO
            and CQ2_DATA   = @cDataF
            and CQ2_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ2###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO \@iRecno
            begin tran
            Insert into CQ2###( CQ2_FILIAL, CQ2_CONTA,  CQ2_CCUSTO, CQ2_MOEDA, CQ2_TPSALD,  CQ2_DATA, CQ2_DEBITO, CQ2_SLBASE, CQ2_STATUS, CQ2_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,   @cSlBase,    @cStatus,  @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ2###
        Set CQ2_DEBITO = CQ2_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /*----------------------------------------------------------------------
        Inicio Atualizacao CREDITO NA TABELA CQ2 - Saldo por C.CUSTO+CONTA MES
        ---------------------------------------------------------------------- */
    If @IN_CUSTOC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
      
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ2
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaC+CustoC existe na tabela de saldos CQ2
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ2###
        Where CQ2_FILIAL = @IN_FILIAL
            and CQ2_CONTA  = @IN_CONTAC
            and CQ2_CCUSTO = @IN_CUSTOC
            and CQ2_MOEDA  = @IN_MOEDA
            and CQ2_TPSALD = @IN_TPSALDO
            and CQ2_DATA   = @cDataF
            and CQ2_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ2###
            select @iRecno = @iRecno + 1
                     
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ2###( CQ2_FILIAL, CQ2_CONTA,  CQ2_CCUSTO, CQ2_MOEDA, CQ2_TPSALD,  CQ2_DATA, CQ2_CREDIT, CQ2_SLBASE, CQ2_STATUS, CQ2_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ2###
        Set CQ2_CREDIT = CQ2_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ2 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ2###
            Set D_E_L_E_T_   = '*'
        Where CQ2_FILIAL   = @IN_FILIAL
            and Round(CQ2_DEBITO, 2) = 0.00
            and Round(CQ2_CREDIT, 2) = 0.00
   	    and CQ2_DATA     = @cDataF
            and ((CQ2_CONTA  = @IN_CONTAC AND CQ2_CCUSTO = @IN_CUSTOC) or (CQ2_CONTA  = @IN_CONTAD AND CQ2_CCUSTO = @IN_CUSTOD))
            and CQ2_TPSALD   = @IN_TPSALDO
            and CQ2_MOEDA    = @IN_MOEDA
            and CQ2_LP       = @cLp
            and D_E_L_E_T_   = ' '
        commit tran
        begin tran
        delete from CQ2###
    Where CQ2_FILIAL   = @IN_FILIAL
        and Round(CQ2_DEBITO, 2) = 0.00
        and Round(CQ2_CREDIT, 2) = 0.00
        and CQ2_DATA     = @cDataF
        and ((CQ2_CONTA  = @IN_CONTAC AND CQ2_CCUSTO = @IN_CUSTOC) or (CQ2_CONTA  = @IN_CONTAD AND CQ2_CCUSTO = @IN_CUSTOD))
        and CQ2_TPSALD   = @IN_TPSALDO
        and CQ2_MOEDA    = @IN_MOEDA
        and CQ2_LP       = @cLp
        and D_E_L_E_T_   = '*'
        commit tran
    end else begin
        begin tran
        delete from CQ2###
    Where CQ2_FILIAL  = @IN_FILIAL
        and Round(CQ2_DEBITO, 2) = 0.00
        and Round(CQ2_CREDIT, 2) = 0.00
   	    and CQ2_DATA     = @cDataF
   	    and ((CQ2_CONTA  = @IN_CONTAC AND CQ2_CCUSTO = @IN_CUSTOC) or (CQ2_CONTA  = @IN_CONTAD AND CQ2_CCUSTO = @IN_CUSTOD))
   	    and CQ2_TPSALD   = @IN_TPSALDO
   	    and CQ2_MOEDA    = @IN_MOEDA
   	    and CQ2_LP       = @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
    End   
    /* -----------------------------------------------------------------------------
        *****************************************************************************
        Inicio Atualizacao DEBITO NA TABELA CQ9 DIA - SALDO POR ENTIDADE CCUSTO
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_CUSTOD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
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
            and CQ9_IDENT  = 'CTT'
            and CQ9_CODIGO = @IN_CUSTOD
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
            Insert into CQ9###( CQ9_FILIAL, CQ9_IDENT,  CQ9_CODIGO, CQ9_MOEDA, CQ9_TPSALD,  CQ9_DATA, CQ9_DEBITO, CQ9_SLBASE, CQ9_STATUS, CQ9_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CTT',      @IN_CUSTOD, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
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
        Inicio Atualizacao CREDITO NA TABELA CQ9 - Saldo por C.CUSTO+CONTA DIA
        ---------------------------------------------------------------------- */
    If @IN_CUSTOC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
      
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
            and CQ9_IDENT  = 'CTT'
            and CQ9_CODIGO = @IN_CUSTOC
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
                        Values( @IN_FILIAL, 'CTT',     @IN_CUSTOC, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
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
            and ((CQ9_IDENT  = 'CTT' AND CQ9_CODIGO = @IN_CUSTOC) or (CQ9_IDENT  = 'CTT' AND CQ9_CODIGO = @IN_CUSTOD))
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
        and ((CQ9_IDENT  = 'CTT' AND CQ9_CODIGO = @IN_CUSTOC) or (CQ9_IDENT  = 'CTT' AND CQ9_CODIGO = @IN_CUSTOD))
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
   	    and ((CQ9_IDENT  = 'CTT' AND CQ9_CODIGO = @IN_CUSTOC) or (CQ9_IDENT  = 'CTT' AND CQ9_CODIGO = @IN_CUSTOD))
   	    and CQ9_TPSALD   = @IN_TPSALDO
   	    and CQ9_MOEDA    = @IN_MOEDA
   	    and CQ9_LP       =  @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
    End
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ8 MES - Saldo por ENTIDADE CCUSTO
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_CUSTOD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
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
            and CQ8_IDENT  = 'CTT'
            and CQ8_CODIGO = @IN_CUSTOD
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
                        Values( @IN_FILIAL, 'CTT',     @IN_CUSTOD,  @IN_MOEDA, @IN_TPSALDO, @cDataF,          0,   @cSlBase,    @cStatus,  @cLp,   @iRecno )
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
        Inicio Atualizacao CREDITO NA TABELA CQ8 - Saldo por C.CUSTO+CONTA MES
        ---------------------------------------------------------------------- */
    If @IN_CUSTOC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
      
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
            and CQ8_IDENT  = 'CTT'
            and CQ8_CODIGO = @IN_CUSTOC
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
                        Values( @IN_FILIAL, 'CTT',     @IN_CUSTOC, @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
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
            and ((CQ8_IDENT  = 'CTT' AND CQ8_CODIGO = @IN_CUSTOC) or (CQ8_IDENT  = 'CTT' AND CQ8_CODIGO = @IN_CUSTOD))
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
        and ((CQ8_IDENT  = 'CTT' AND CQ8_CODIGO = @IN_CUSTOC) or (CQ8_IDENT  = 'CTT' AND CQ8_CODIGO = @IN_CUSTOD))
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
   	    and ((CQ8_IDENT  = 'CTT' AND CQ8_CODIGO = @IN_CUSTOC) or (CQ8_IDENT  = 'CTT' AND CQ8_CODIGO = @IN_CUSTOD))
   	    and CQ8_TPSALD   = @IN_TPSALDO
   	    and CQ8_MOEDA    = @IN_MOEDA
   	    and CQ8_LP       = @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
    End
   
    select @OUT_RESULT = '1'
End
