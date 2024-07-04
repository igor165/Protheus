Create Procedure CTB180_##(
   @IN_FILIAL      Char( 'CQ0_FILIAL' ),
   @IN_OPER        Char( 01 ),
   @IN_DC          Char( 01 ),
   @IN_CONTAD      Char( 'CQ0_CONTA' ),
   @IN_CONTAC      Char( 'CQ0_CONTA' ),
   @IN_MOEDA       Char( 'CQ0_MOEDA' ),
   @IN_DATA        Char( 08 ),
   @IN_TPSALDO     Char( 'CQ0_TPSALD' ),
   @IN_DTLP        Char( 08 ),
   @IN_VALOR       Float,
   @IN_INTEGRIDADE Char( 01 ),
   @OUT_RESULT     Char( 01 ) OutPut

)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Atualiza Débito</d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
      						   @IN_OPER         - Operacao Aritmética ( '+' = Somar '-' = Subtrair )
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTAC       - Conta a Crédito
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
declare @cAuxDC      VarChar( 01 )
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
        Inicio Atualizacao Debito na tabela CQ1 DIA - Saldo por Conta
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_CONTAD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
   
        /* ---------------------------------------------------------------------
            Verifica se a ctaD existe na tabela de saldos CQ1
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
          From CQ1###
         Where CQ1_FILIAL = @IN_FILIAL
           and CQ1_CONTA  = @IN_CONTAD
           and CQ1_MOEDA  = @IN_MOEDA
           and CQ1_TPSALD = @IN_TPSALDO
           and CQ1_DATA   = @IN_DATA
           and CQ1_LP     = @cLp
           and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
        /* ---------------------------------------------------------------------
            Se não existe Inclui
            --------------------------------------------------------------------- */
        If @iRecno = 0 begin
         
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ1###
            select @iRecno = @iRecno + 1

            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ1###( CQ1_FILIAL, CQ1_CONTA,  CQ1_MOEDA,  CQ1_TPSALD,  CQ1_DATA, CQ1_DEBITO, CQ1_SLBASE, CQ1_STATUS,  CQ1_LP,   R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_MOEDA,  @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,   @cStatus,    @cLp,     @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ1###
        Set CQ1_DEBITO = CQ1_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /*---------------------------------------------------------------
        Inicio Atualizacao Credito na tabela CQ1 - Saldo por Conta
        --------------------------------------------------------------- */      
    If @IN_CONTAC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' ) begin
      
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------------
            Verifica se a ctaC existe na tabela de saldos CQ1
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ1###
        Where CQ1_FILIAL = @IN_FILIAL
            and CQ1_CONTA  = @IN_CONTAC
            and CQ1_MOEDA  = @IN_MOEDA
            and CQ1_TPSALD = @IN_TPSALDO
            and CQ1_DATA   = @IN_DATA
            and CQ1_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
        
        If @iRecno = 0 begin
         
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ1###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ1###( CQ1_FILIAL, CQ1_CONTA,  CQ1_MOEDA, CQ1_TPSALD,  CQ1_DATA, CQ1_CREDIT, CQ1_SLBASE, CQ1_STATUS, CQ1_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ1###
        Set CQ1_CREDIT = CQ1_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ1 c/deb e cred Zerados      
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ1###
           Set D_E_L_E_T_ = '*'
         Where CQ1_FILIAL  = @IN_FILIAL
           and Round(CQ1_DEBITO, 2) = 0.00
           and Round(CQ1_CREDIT, 2) = 0.00 
           and CQ1_DATA     = @IN_DATA
           and ((CQ1_CONTA  = @IN_CONTAC) or (CQ1_CONTA = @IN_CONTAD))
           and CQ1_TPSALD   = @IN_TPSALDO
           and CQ1_MOEDA    = @IN_MOEDA
           and CQ1_LP        = @cLp
   	       and D_E_L_E_T_   = ' '

        delete from CQ1###
              Where CQ1_FILIAL  = @IN_FILIAL
                and Round(CQ1_DEBITO, 2) = 0.00
                and Round(CQ1_CREDIT, 2) = 0.00 
                and CQ1_DATA     = @IN_DATA
                and ((CQ1_CONTA  = @IN_CONTAC) or (CQ1_CONTA = @IN_CONTAD))
                and CQ1_TPSALD   = @IN_TPSALDO
                and CQ1_MOEDA    = @IN_MOEDA
                and CQ1_LP       = @cLp
                and D_E_L_E_T_   = '*'
        commit tran
    end else begin
        begin tran
        delete from CQ1###
        Where CQ1_FILIAL  = @IN_FILIAL
            and Round(CQ1_DEBITO, 2) = 0.00
            and Round(CQ1_CREDIT, 2) = 0.00
   	        and CQ1_DATA     = @IN_DATA
   	        and ((CQ1_CONTA  = @IN_CONTAC) or (CQ1_CONTA = @IN_CONTAD))
   	        and CQ1_TPSALD   = @IN_TPSALDO
   	        and CQ1_MOEDA    = @IN_MOEDA
   	        and CQ1_LP       = @cLp
   	        and D_E_L_E_T_   = ' '
        commit tran
    End
    /*-----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ0 MES - Saldo por Conta
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_CONTAD != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------------
            Verifica se a ctaD existe na tabela de saldos CQ0
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
          From CQ0###
         Where CQ0_FILIAL = @IN_FILIAL
           and CQ0_CONTA  = @IN_CONTAD
           and CQ0_MOEDA  = @IN_MOEDA
           and CQ0_TPSALD = @IN_TPSALDO
           and CQ0_DATA   = @cDataF
           and CQ0_LP     = @cLp
           and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
        /* ---------------------------------------------------------------------
            Se não existe Inclui
            --------------------------------------------------------------------- */
        If @iRecno = 0 begin
         
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ0###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ0###( CQ0_FILIAL, CQ0_CONTA,  CQ0_MOEDA,  CQ0_TPSALD,  CQ0_DATA, CQ0_DEBITO, CQ0_SLBASE, CQ0_STATUS,  CQ0_LP,   R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_MOEDA,  @IN_TPSALDO, @cDataF,           0,   @cSlBase,   @cStatus,    @cLp,     @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ0###
        Set CQ0_DEBITO = CQ0_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /*---------------------------------------------------------------
        Inicio Atualizacao Credito na tabela CQ0 - Saldo por Conta
        --------------------------------------------------------------- */      
    If @IN_CONTAC != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' ) begin
      
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------------
            Verifica se a ctaC existe na tabela de saldos CQ0
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START        
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
          From CQ0###
         Where CQ0_FILIAL = @IN_FILIAL
           and CQ0_CONTA  = @IN_CONTAC
           and CQ0_MOEDA  = @IN_MOEDA
           and CQ0_TPSALD = @IN_TPSALDO
           and CQ0_DATA   = @cDataF
           and CQ0_LP     = @cLp
           and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
         
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ0###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            begin tran
            Insert into CQ0###( CQ0_FILIAL, CQ0_CONTA,  CQ0_MOEDA, CQ0_TPSALD,  CQ0_DATA, CQ0_CREDIT, CQ0_SLBASE, CQ0_STATUS, CQ0_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            commit tran
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um Update
        --------------------------------------------------------------------- */
        begin tran
        Update CQ0###
        Set CQ0_CREDIT = CQ0_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        commit tran
    End
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ0 c/deb e cred Zerados      
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        begin tran
        Update CQ0###
            Set D_E_L_E_T_ = '*'
        Where CQ0_FILIAL  = @IN_FILIAL
            and Round(CQ0_DEBITO, 2) = 0.00
            and Round(CQ0_CREDIT, 2) = 0.00 
            and CQ0_DATA     = @cDataF
            and ((CQ0_CONTA  = @IN_CONTAC) or (CQ0_CONTA = @IN_CONTAD))
            and CQ0_TPSALD   = @IN_TPSALDO
        and CQ0_MOEDA    = @IN_MOEDA
        and CQ0_LP       = @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
        begin tran
        delete from CQ0###
            Where CQ0_FILIAL  = @IN_FILIAL
                and Round(CQ0_DEBITO, 2) = 0.00
                and Round(CQ0_CREDIT, 2) = 0.00 
                and CQ0_DATA     = @cDataF
                and ((CQ0_CONTA  = @IN_CONTAC) or (CQ0_CONTA = @IN_CONTAD))
                and CQ0_TPSALD   = @IN_TPSALDO
                and CQ0_MOEDA    = @IN_MOEDA
                and CQ0_LP       = @cLp
                and D_E_L_E_T_   = '*'
        commit tran
    end else begin
        begin tran
        delete from CQ0###
    Where CQ0_FILIAL  = @IN_FILIAL
        and Round(CQ0_DEBITO, 2) = 0.00
        and Round(CQ0_CREDIT, 2) = 0.00
   	    and CQ0_DATA     = @cDataF
   	    and ((CQ0_CONTA  = @IN_CONTAC) or (CQ0_CONTA = @IN_CONTAD))
   	    and CQ0_TPSALD   = @IN_TPSALDO
   	    and CQ0_MOEDA    = @IN_MOEDA
   	    and CQ0_LP       = @cLp
   	    and D_E_L_E_T_   = ' '
        commit tran
    End
    select @OUT_RESULT = '1'
End
