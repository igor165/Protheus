Create procedure FIN003_##
(
   @IN_MVPAR01     Char(01),
   @IN_MVPAR02     Char(01),
   @IN_MCUSTO      Char(01),
   @IN_DATABASE    Char(08),
   @IN_TIPOCR      VarChar(250),
   @IN_TIPOCR1     VarChar(250),
   @IN_TIPOCP      VarChar(250),
   @IN_TIPOLC      VarChar(250),
   @IN_CLIDE       Char( 'A1_COD' ),
   @IN_CLIATE      Char( 'A1_COD' ),
   @IN_FORDE       Char( 'A2_COD' ),
   @IN_FORATE      Char( 'A2_COD' ),
   @IN_TAMFIL      Integer,
   @IN_MODULO      Float,
   @IN_CLIPAD      Char( 'E1_CLIENTE' ),
   @IN_LOJPAD      char( 'E1_LOJA' ),
   @IN_SCFILTRO    Char(01), 
   @OUT_RESULTADO  char(1) OutPut
)
As
/* -------------------------------------------------------------------------------------
   Programa        - <s> FINA410 </s>
   Versão          - <v> Protheus P11 </v>
   Assinatura      - <a> 012 </a>
   Procedure       - Recalculo de saldos de clientes e fornecedores
   Descricao       - <d> Recalculo de saldos de clientes e fornecedores </d>
   Entrada         - <ri>@IN_MVPAR01    - Opcao para recalculo, 1-Ambos, 2-Clientes, 3-Fornecedores
                         @IN_MVPAR02    - Opcao para recalculo de historico
                         @IN_MCUSTO     - Moeda Forte utilizada para conversão dos valores dos titulos
                         @IN_DATABASE   - Data Base do sistema
                         @IN_TIPOCR     - Títulos excluídos dos saldos de clientes - 
                                          "/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM+"/"+MVIRABT+"/"+MVFUABT+
                                          "/"+MVINABT+"/"+MVISABT+"/"+MVPIABT+"/"+MVCFABT
                         @IN_TIPOCR1    - Títulos em atraso dos saldos de clientes devem se diferentes de - 
                                          "/"+MVRECANT+"/"+MV_CRNEG
                         @IN_TIPOCP     - Títulos excluídos dos saldos de fornecedores -
                                          "/"+MVPAGANT+"/"+MV_CPNEG+"/"+MVABATIM
                         @IN_TIPOLC    - limites de credito.
                         @IN_CLIDE     - Range Inicial de cliente
                         @IN_CLIATE    - Range Final de Cliente
                         @IN_FORDE     - Range Inicial de Fornecedores
                         @IN_FORATE    - Range Final de Fornecedores
                         @IN_TAMFIL    - Tamanho da Filial de 2 a 12
                         @IN_MODULO    - modulo
                         @IN_CLIPAD    - Cliente padrao ( sigaloja )
                         @IN_LOJPAD    - Loja padrao ( sigaloja ) < /ri>
   Saida       - <ro> @OUT_RESULTADO - Indica o termino OK da procedure </ro>
   Responsavel - <r>  Marcelo Rodrigues de Oliveira	</r>
   Data               04/04/2002 

   Estrutura de chamadas
   ========= == ========

   0.FIN003 - Recalculo de saldos de clientes e fornecedores
     1.MAT021 - Converte valor da moeda origem para moeda destino com base na data
       2.MAT020  -  Recupera taxa para moeda na data em questao

   --------------------------------------------------------------------------------------*/
declare @cFil_A1_Ant     char('A1_FILIAL')
declare @cFil_A2_Ant     char('A2_FILIAL')
declare @cFil_E1_Ant     char('E1_FILIAL')
declare @cFil_E2_Ant     char('E2_FILIAL')
declare @cFilial_A1      char('A1_FILIAL')
declare @cFilial_A2      char('A2_FILIAL')
declare @cFilial_E1      char('E1_FILIAL')
declare @cFilial_E2      char('E2_FILIAL')
declare @cFilial_E5      char('E5_FILIAL')
declare @cFilial_F1      char('F1_FILIAL')
declare @cFilial_F2      char('A1_FILIAL')
declare @cFilial         char('A1_FILIAL')
declare @cMsFil          char('A1_FILIAL')
declare @iprimeiro_recno integer
declare @iultimo_recno   integer
declare @nValor          Float
declare @nSaldo          Float
declare @nValLiq         Float
declare @nVlcruz         Float
declare @cCliente        Char('A1_COD')
declare @cLoja           Char('A1_LOJA')
declare @cCliAux         Char('A1_COD')
declare @cLojaAux        Char('A1_LOJA')
declare @nMoeda          Float
declare @cEmissao        Char(08)
declare @cTipo           Char('E1_TIPO')
declare @cVencto         Char(08)
declare @cVencReal       Char(08)
declare @cBaixa          Char(08)
declare @nMoedaForte     float
declare @nA1_SALDUP      float
declare @nA1_SALDUPM     float
declare @nA1_SALFIN      float
declare @nA1_SALFINM     float
declare @nA1_MAIDUPL     float
declare @nA1_ATR         float
declare @nA1_PAGATR      float
declare @nA1_NROPAG      float
declare @nA1_VACUM       float
declare @nA1_MOEDALC     float
declare @nA1_MSALDO      float
declare @nA1_MATR        float
declare @nA1_METR        float
declare @nA1_MCOMPRA     float
declare @nA1_NROCOM      float
declare @cA1_PRICOM      char('A1_PRICOM')
declare @cA1_ULTCOM      char('A1_ULTCOM')
declare @iPos            Integer
declare @iPos1           Integer
declare @iPosFil         Integer
declare @nSaldoTit       float
declare @cFornece        char('A2_COD')
declare @nMoedaSalDup    float
declare @nMoedaSalDupM   float
declare @nMoedaSalFin    float
declare @nMoedaSalFinM   float
declare @nMoedaMaiDup    float
declare @nSaldoAcum      float
declare @nMCompra        float
declare @nMSaldo         float
declare @nMSaldoAux      float 
Declare @nA2_SALDUP      float
Declare @nA2_SALDUPM     float
Declare @nA2_MCOMPRA     float
Declare @nA2_MNOTA       float
Declare @nA2_MSALDO      float
Declare @nA2_NROCOM      float
Declare @nValorAux       float
declare @cA2_PRICOM      char( 'A2_PRICOM' )
declare @cA2_ULTCOM      char( 'A2_ULTCOM' )
declare @cAux            Varchar(3)
declare @nAux            integer
declare @iRecnoLocaliz   integer
declare @iDiferencaDATA  integer
declare @cPrefixo        char( 'E1_PREFIXO' )
declare @cNum            char( 'E1_NUM' )
declare @cParcela        char( 'E1_PARCELA' )
declare @nQtdBaixas      integer
declare @cOrigem         char('E1_ORIGEM')
declare @cOrigemAux      char('E1_ORIGEM')
declare @nF2_VALFAT      float
declare @lA1Zerado       char(01)
declare @lA2Zerado       char(01)
declare @cFatura         char( 'E1_FATURA' )
declare @cPedido         char( 'E1_PEDIDO' )
declare @cPedAux         char( 'E1_PEDIDO' )
declare @lExecE1         Char(01)
declare @lExecE2         Char(01)
declare @iNroRegs        Integer   -- Controle de cOMMITS
declare @iTranCount      Integer --Var.de ajuste para SQLServer e Sybase.
                                 -- Será trocada por Commit no CFGX051 após passar pelo Parse
declare @lLojaCartao     Char( 01 ) -- Origem e o SIGALOJA
declare @cCliente_SF2    Char( 'F2_CLIENTE' )
declare @cLoja_SF2       Char( 'F2_LOJA' )
declare @nF1_VALBRUT     float
declare @cF1_EMISSAO     Char( 08 )
declare @nMaiorVda       float
declare @iRecnoSF2       Integer
declare @cSerie          Char( 'E1_SERIE' )
declare @lNroExecSE1     Char( 01 )
declare @lNroExecSE2     Char( 01 )

declare @nFil			integer
declare @nTotFil		integer

declare @nResult         Char( 01 )

BEGIN
   select @OUT_RESULTADO  = '0'
   select @nMoeda         = 0
   select @iDiferencaDATA = 0
   select @iNroRegs       = 0
   select @nMoedaForte = Convert(Float, @IN_MCUSTO)
   select @lA1Zerado = '0'
   select @lA2Zerado = '0'
   select @lExecE1   = '1'
   select @lExecE2   = '1'
   Select @cCliente_SF2 = ''
   Select @cLoja_SF2 = ''
   select @iRecnoSF2 = 0

   select @cFil_A1_Ant = '0'
   select @cFil_A2_Ant = '0'
   select @cFil_E1_Ant = ''
   select @cFil_E2_Ant = ''
   
   /*
   IMPORTANTE
   Ignorado ponto de entrada contido no fonte padrao pois o mesmo foi implementado por localizacoes, como os responsaveis
   pelo financeiro ( PILAR / PEQUIM ) nem sabiam da existencia e do porque do ponto de entrada, ele foi ignorado, assim
   que descobrirem para quem e o que faz esse ponto de entrada será implementado aqui, mas já adiantando, acarretará em
   uma perda considerável de performance.
   */
   select @iPosFil = 1
   select @cPedAux = ''
   select @nMSaldo = 0
   select @cCliAux  = ''
   select @cLojaAux = ''
   select @lNroExecSE1 = '0'
   select @lNroExecSE2 = '0'   

   select @nFil = 1
   select @nTotFil = MAX(TRR_ID) from TRR###


   While @nFil <= @nTotFil begin
      select @cFilial = TRR_FILIAL from TRR### where TRR_ID = @nFil

      select @cAux = 'SA1'
      exec XFILIAL_## @cAux, @cFilial, @cFilial_A1 Output
      select @cAux = 'SA2'
      exec XFILIAL_## @cAux, @cFilial, @cFilial_A2 Output
      select @cAux = 'SE1'
      exec XFILIAL_## @cAux, @cFilial, @cFilial_E1 Output
      select @cAux = 'SE2'
      exec XFILIAL_## @cAux, @cFilial, @cFilial_E2 Output
      select @cAux = 'SE5'
      exec XFILIAL_## @cAux, @cFilial, @cFilial_E5 Output
      select @cAux = 'SF1'
      exec XFILIAL_## @cAux, @cFilial, @cFilial_F1 Output
      select @cAux = 'SF2'
      exec XFILIAL_## @cAux, @cFilial, @cFilial_F2 Output
      /* -------------------------------------------------------------------------------------
         Dados dos clientes devem ser atualizados
          Se A1 for compartilhado zero apenas uma vez, pois o A1 deve ter dados consolidados
          no caso em que A1 é Compartilhado e E1 e Exclusivo
         ------------------------------------------------------------------------------------- */
      If @cFilial_A1 = @cFil_A1_Ant begin    
         select @lA1Zerado = '1'
      End
      If @cFilial_A2 = @cFil_A2_Ant begin
         select @lA2Zerado = '1'
      End
      if ( @IN_MVPAR01 <> '3' ) begin
         If @lExecE1 = '1' begin
            If @lA1Zerado = '0' begin
               If @cFilial_A1 = ' ' select @lA1Zerado = '1'
               select @iprimeiro_recno = isnull( min( R_E_C_N_O_ ), 0 ), @iultimo_recno = isnull( max( R_E_C_N_O_ ) , 0 )
                 from SA1###
                where A1_FILIAL  = @cFilial_A1
                  and A1_COD     between @IN_CLIDE and @IN_CLIATE
                  and D_E_L_E_T_ = ' '
               /*----------------------------------------------------------------------------------------------
                 Fazendo UPDATE por blocos.
                 ----------------------------------------------------------------------------------------------*/
               while ( @iprimeiro_recno <= @iultimo_recno ) begin
                  
                  --Zerando tambem campos de historico
                  begin tran
                  /* -------------------------------------------------------------------------------------
                     Avalia existencia de ponto de entrada e chama proc de processamento 
                  ------------------------------------------------------------------------------------- */
              		if (@IN_SCFILTRO = '2') begin
						   exec F410SCFT_A1_## @IN_MVPAR02,  @cFilial_A1, @IN_CLIDE, @IN_CLIATE, @iprimeiro_recno
    				   end
                  else begin
                     if ( @IN_MVPAR02 = '1' ) begin
                        update SA1###
                           set A1_SALDUP = 0,   A1_SALDUPM = 0, A1_SALFIN  = 0, A1_SALFINM = 0, A1_VACUM   = 0,
                              A1_METR   = 0,   A1_MATR    = 0, A1_MAIDUPL = 0, A1_ATR     = 0, A1_PAGATR  = 0, A1_NROPAG = 0,
                              A1_ULTCOM = ' ', A1_MCOMPRA = 0, A1_NROCOM = 0
                        where A1_FILIAL = @cFilial_A1
                           and A1_COD     between @IN_CLIDE and @IN_CLIATE
                           and R_E_C_N_O_ between @iprimeiro_recno and @iprimeiro_recno + 1024
                           and D_E_L_E_T_ = ' '
                     end else begin
                        --Nao Zerando campos de historico
                        update SA1###
                           Set A1_SALDUP = 0, A1_SALDUPM = 0, A1_SALFIN = 0, A1_SALFINM = 0, A1_VACUM   = 0
                        where A1_FILIAL  = @cFilial_A1
                           and A1_COD     between @IN_CLIDE and @IN_CLIATE
                           and R_E_C_N_O_ between @iprimeiro_recno and @iprimeiro_recno + 1024
                           and D_E_L_E_T_ = ' '
                     end
                  end
                  commit tran
                  select @iprimeiro_recno = @iprimeiro_recno + 1024
                  
               End
            end
         end
      end
      /* -------------------------------------------------------------------------------------
         Dados dos Fornecedores devem ser atualizados
       ------------------------------------------------------------------------------------- */
      if ( @IN_MVPAR01 <> '2' ) begin 
         If @lExecE2 = '1' begin
            If @lA2Zerado = '0' begin
               If @cFilial_A2 = ' ' select @lA2Zerado = '1'
               select @iprimeiro_recno = isnull(min(R_E_C_N_O_), 0), @iultimo_recno = isnull(max(R_E_C_N_O_) , 0)
                 from SA2###
                where A2_FILIAL  = @cFilial_A2
                  and A2_COD     between @IN_FORDE and @IN_FORATE
                  and D_E_L_E_T_ = ' '
               
               while @iprimeiro_recno <= @iultimo_recno begin
                  /* -------------------------------------------------------------------------------------
                     Controle de commit
                   ------------------------------------------------------------------------------------- */
                  begin tran
                  /* -------------------------------------------------------------------------------------
                     Avalia existencia de ponto de entrada e chama proc de processamento 
                  ------------------------------------------------------------------------------------- */
                  if (@IN_SCFILTRO = '2') begin
                     exec F410SCFT_A2_## @IN_MVPAR02,  @cFilial_A2, @IN_FORDE, @IN_FORATE, @iprimeiro_recno
                  end
                  else 
                  begin
                     if ( @IN_MVPAR02 = '1' ) begin
                        update SA2### 
                           Set A2_SALDUP = 0, A2_SALDUPM = 0, A2_MCOMPRA = 0, A2_MNOTA = 0, A2_NROCOM = 0
                     where A2_FILIAL = @cFilial_A2 
                        and A2_COD     between @IN_FORDE and @IN_FORATE
                        and R_E_C_N_O_ Between @iprimeiro_recno and @iprimeiro_recno + 1024 
                        and D_E_L_E_T_ = ' '
                     end else begin
                        --Nao Zerando campos de historico
                        update SA2### 
                           Set A2_SALDUP = 0, A2_SALDUPM = 0, A2_MCOMPRA = 0, A2_MNOTA = 0
                        where A2_FILIAL = @cFilial_A2 
                           and A2_COD     between @IN_FORDE and @IN_FORATE
                           and R_E_C_N_O_ Between @iprimeiro_recno and @iprimeiro_recno + 1024
                           and D_E_L_E_T_ = ' '
                     end
                  end 
                  commit tran
                  select @iprimeiro_recno = @iprimeiro_recno + 1024

               End
            end
         end
      end
      /*-------------------------------------------------------------------
          Se as filiais de SE1 e SA1 são exclusivas pego filial do SE1
         ------------------------------------------------------------------- */ 
      if ( @cFilial_E1 <> ' ' ) and ( @cFilial_A1 <> ' ' ) and @IN_TAMFIL = 2 begin
         select @cFilial_A1 = @cFilial_E1
      end
      /* -------------------------------------------------------------------------------------
         Se as filiais de SE2 e SA2 são exclusivas pego filial do SE2
         ------------------------------------------------------------------------------------- */   
      if ( @cFilial_E2 <> ' ' ) and ( @cFilial_A2 <> ' ' ) and @IN_TAMFIL = 2 begin
         select @cFilial_A2 = @cFilial_E2
      end
      if ( @IN_MVPAR01 <> '3' ) and (( @lNroExecSE1 = '0' ) or ( @cFil_E1_Ant  <> @cFilial_E1 ) or ( @cFil_A1_Ant  <> @cFilial_A1)) begin
         If @lExecE1 = '1' begin
            
            select @iNroRegs = 0
            select @lNroExecSE1 = '1'
            /* -------------------------------------------------------------------------------------
               Avalia existencia de ponto de entrada e chama proc de processamento 
               ------------------------------------------------------------------------------------- */
            /*TRATAMENTO ESPECIFICO PARA O MSSQL, POSTERIOR IMPLEMENTAÇÃO EM OUTROS BANCOS */
            ##IF_001({|| AllTrim(Upper(TcGetDB())) == "MSSQL" })
            if (@IN_SCFILTRO = '2') 
            begin
               exec F410SCFT_E1_## @cFilial_E1, @cFilial_A1, @IN_CLIDE, @IN_CLIATE, @nResult
            END
            ELSE
            ##ENDIF_001
            begin
               declare curSE1 cursor for
               select E1_VALOR,  E1_SALDO , E1_VALLIQ , E1_VLCRUZ, E1_CLIENTE, E1_LOJA, E1_MOEDA,  E1_EMISSAO, 
                     E1_TIPO ,  E1_VENCTO, E1_VENCREA, E1_BAIXA,  E1_PREFIXO, E1_NUM,  E1_PARCELA, E1_ORIGEM,
                     E1_FATURA, E1_MSFIL , E1_PEDIDO, E1_SERIE
                  from SE1### SE1, SA1### SA1
               where SE1.E1_FILIAL  = @cFilial_E1
                  and SA1.A1_FILIAL  = @cFilial_A1
                  and SA1.A1_COD     between @IN_CLIDE AND @IN_CLIATE
                  and SA1.A1_COD     = SE1.E1_CLIENTE
                  and SA1.A1_LOJA    = SE1.E1_LOJA
                  and SE1.D_E_L_E_T_ = ' '
                  and SA1.D_E_L_E_T_ = ' '
            end
            open  curSE1 
            fetch curSE1 into @nValor, @nSaldo,  @nValLiq,   @nVlcruz, @cCliente, @cLoja, @nMoeda, @cEmissao,
                  @cTipo,  @cVencto, @cVencReal, @cBaixa, @cPrefixo, @cNum, @cParcela, @cOrigem, @cFatura, @cMsFil, @cPedido, @cSerie
            while ( @@fetch_status = 0 ) begin
               /* -------------------------------------------------------------------------------------
                  Controle de commits
                  ------------------------------------------------------------------------------------- */
               select @iNroRegs = @iNroRegs + 1
               /* -------------------------------------------------------------------------------------
                  Qdo a origem do movimento e o SIGALOJA
                  CC - Cartao de Credito
                  VA - Vales
                  CO - Convenio
                  CD - Cartao de Debito
                  FI - Financiamento Proprio
                  ------------------------------------------------------------------------------------- */
               select @lLojaCartao = '0'
               If Substring( @cOrigem, 1, 3 ) = 'LOJ' begin
                  If @cTipo in ( 'CC', 'VA', 'CO','CD','FI') begin
                     select @lLojaCartao = '1'
                  End
               End
               
               if @lLojaCartao = '1' begin
                  
                  If @cFilial_F2 <> ' ' begin
                     select @cFilial_F2 = @cMsFil
                  End
                  
                  Select @cCliente_SF2 = F2_CLIENTE, @cLoja_SF2 = F2_LOJA
                    From SF2###
                   Where F2_FILIAL  = @cFilial_F2
                     and F2_DOC     = @cNum
                     and F2_PREFIXO = @cPrefixo
                     and D_E_L_E_T_ = ' '
                  
                  If @cCliente_SF2 <> ' ' select @cCliente = @cCliente_SF2
                  If @cLoja_SF2 <> ' ' select @cLoja = @cLoja_SF2
               End
               /* -------------------------------------------------------------------------------------
                  Recupera o cliente a ser atualizado
                  ------------------------------------------------------------------------------------- */
               select @nA1_SALDUP = A1_SALDUP,  @nA1_SALDUPM = A1_SALDUPM,
                      @nA1_MAIDUPL= A1_MAIDUPL, @nA1_ATR     = A1_ATR,
                      @nA1_PAGATR = A1_PAGATR,  @nA1_NROPAG  = A1_NROPAG,
                      @nA1_VACUM  = A1_VACUM,   @cA1_PRICOM  = A1_PRICOM ,
                      @cA1_ULTCOM = A1_ULTCOM,  @nA1_MOEDALC = A1_MOEDALC,
                      @nA1_SALFIN = A1_SALFIN,  @nA1_SALFINM = A1_SALFINM, 
                      @nA1_MSALDO = A1_MSALDO,  @nA1_MATR    = A1_MATR,
                      @nA1_METR   = A1_METR,    @nA1_MCOMPRA = A1_MCOMPRA,
                      @nA1_NROCOM = A1_NROCOM
                 from SA1###
                where A1_FILIAL   = @cFilial_A1
                  and A1_COD      = @cCliente
                  and A1_LOJA     = @cLoja
                  and D_E_L_E_T_  = ' '
               
               select @nMoedaSalDup  = 0
               select @nMoedaSalDupM = 0
               select @nMoedaSalFin  = 0
               select @nMoedaSalFinM = 0
               select @nMoedaMaiDup  = 0
               select @nMaiorVda     = 0
               select @nMSaldoAux    = 0
               select @nSaldoAcum    = 0
               select @iPos          = 0
               select @iPos1         = 0
               select @nQtdBaixas    = 0
               if ( @nA1_MOEDALC > 0 and @nA1_MOEDALC is not NULL ) select @nMoedaForte = @nA1_MOEDALC
               if ( (@cCliente || @cLoja) <> (@cCliAux || @cLojaAux) ) begin
                   select @cCliAux  = @cCliente
                   select @cLojaAux = @cLoja
                   select @nMSaldo  = 0
               end
               /* ------------------------------------------------------------------------------
                  VERIFICA SE @cTipo (E1_TIPO) ESTÁ EM @IN_TIPOCR - SUBTRAIO
                  @IN_TIPOCR = "/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM+"/"+MVIRABT+"/"+MVFUABT+
                               "/"+MVINABT+"/"+MVISABT+"/"+MVPIABT+"/"+MVCFABT
                  ------------------------------------------------------------------------------- */ 
               select @iPos = Charindex( '/' || @cTipo, @IN_TIPOCR ) 
               if @iPos = 0 select @iPos = Charindex( '|' || @cTipo, @IN_TIPOCR )
               if @iPos > 0 begin
                  /* ------------------------------------------------------------------------------
                     VERIFICA SE @cTipo (E1_TIPO) ESTÁ EM @IN_TIPOLC - AtuSaldup
                     ------------------------------------------------------------------------------- */ 
                  select @iPos1 = Charindex('/' || @cTipo, @IN_TIPOLC) 
                  if @iPos1 = 0 select @iPos1 = Charindex('|' || @cTipo,@IN_TIPOLC)
                  if @iPos1 <> 0 begin
                     select @nAux = 1
                     exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nAux, @nMoedaSalFin output
                     exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nMoedaForte, @nMoedaSalFinM output
                     select @nA1_SALFIN  = @nA1_SALFIN  - @nMoedaSalFin
                     select @nA1_SALFINM = @nA1_SALFINM - @nMoedaSalFinM
                  end else begin
                     select @nAux = 1
                     exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nAux, @nMoedaSalDup output
                     exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nMoedaForte, @nMoedaSalDupM output
                     select @nA1_SALDUP  = @nA1_SALDUP  - @nMoedaSalDup
                     select @nA1_SALDUPM = @nA1_SALDUPM - @nMoedaSalDupM
                  end
               end else begin
                  /* -------------------------------------------------------------------------------
                  SE @cTipo (E1_TIPO) NÃO ESTÁ EM @IN_TIPORC - SOMO
                  ------------------------------------------------------------------------------- */ 
                  select @nSaldoTit = @nSaldo
                  /* -------------------------------------------------------------------------------
                  VERIFICA SE @cTipo (E1_TIPO) ESTÁ EM @IN_TIPOLC  - AtuSaldup
                  ------------------------------------------------------------------------------- */ 
                  select @iPos1 = Charindex('/' || @cTipo, @IN_TIPOLC) 
                  if @iPos1 = 0 select @iPos1 = Charindex('|' || @cTipo,@IN_TIPOLC)
                  if @iPos1 <> 0 begin
                     select @nAux = 1
                     exec MAT021_## @nSaldoTit, @cEmissao, @nMoeda, @nAux, @nMoedaSalFin output
                     exec MAT021_## @nSaldoTit, @cEmissao, @nMoeda, @nMoedaForte, @nMoedaSalFinM output
                     select @nA1_SALFIN  = @nA1_SALFIN  + @nMoedaSalFin
                     select @nA1_SALFINM = @nA1_SALFINM + @nMoedaSalFinM
                  end else begin
                     select @nAux = 1
                     exec MAT021_## @nSaldoTit, @cEmissao, @nMoeda, @nAux, @nMoedaSalDup output
                     exec MAT021_## @nSaldoTit, @cEmissao, @nMoeda, @nMoedaForte, @nMoedaSalDupM output
                     select @nA1_SALDUP  = @nA1_SALDUP  + @nMoedaSalDup
                     select @nA1_SALDUPM = @nA1_SALDUPM + @nMoedaSalDupM
                  end
                  if @cA1_PRICOM is null or @cA1_PRICOM > @cEmissao select @cA1_PRICOM = @cEmissao
                  
                  if ( @IN_MVPAR02 = '1' ) begin
                     if @cA1_ULTCOM is null or @cA1_ULTCOM < @cEmissao select @cA1_ULTCOM = @cEmissao
                  End
                  
                  if (substring(@cEmissao, 1, 4) = substring(@IN_DATABASE, 1, 4) and @cOrigem != 'FINA280' ) begin
                     exec MAT021_## @nValor, @cEmissao, @nMoeda, @nMoedaForte, @nSaldoAcum output
                     select @nA1_VACUM = @nA1_VACUM + @nSaldoAcum
                  end
                  select @cOrigemAux = @cOrigem
                  /* -------------------------------------------------------------------------------
                     SE @cTipo nao for provisorio
                     ------------------------------------------------------------------------------- */ 
                  If @cTipo != 'PR ' begin
                     If @cOrigemAux = 'MATA460' begin
                        
                        If @cFilial_F2 <> ' ' and @cMsFil != ' ' begin
                        	select @cFilial_F2 = @cMsFil 
                        End
                        
                        select @iRecnoSF2 = IsNull(R_E_C_N_O_, 0)
                         from SF2###
                        Where F2_FILIAL  = @cFilial_F2
                          and F2_CLIENTE = @cCliente
                          and F2_LOJA    = @cLoja
                          and F2_DOC     = @cNum
                          and F2_PREFIXO = @cPrefixo
                          and D_E_L_E_T_ = ' '
                        /* -------------------------------------------------
                           SE nao achar prefixo no SF2 , PROCURO PELA SERIE
                           ------------------------------------------------- */                         
                        If @iRecnoSF2 = 0 begin
                           select @nF2_VALFAT = IsNull(F2_VALFAT, 0)
                            from SF2###
                           Where F2_FILIAL  = @cFilial_F2
                             and F2_CLIENTE = @cCliente
                             and F2_LOJA    = @cLoja
                             and F2_DOC     = @cNum
                             and F2_SERIE   = @cSerie
                             and D_E_L_E_T_ = ' '
                        End else begin
                           select @nF2_VALFAT = IsNull(F2_VALFAT, 0)
                            from SF2###
                           Where F2_FILIAL  = @cFilial_F2
                             and F2_CLIENTE = @cCliente
                             and F2_LOJA    = @cLoja
                             and F2_DOC     = @cNum
                             and F2_PREFIXO = @cPrefixo
                             and D_E_L_E_T_ = ' '
                        End
                        exec MAT021_## @nF2_VALFAT, @cEmissao, @nMoeda, @nMoedaForte, @nMaiorVda output
                     end else begin
                        exec MAT021_## @nValor, @cEmissao, @nMoeda, @nMoedaForte, @nMaiorVda output
                     end
                     If ( @nA1_MCOMPRA < @nMaiorVda ) select @nA1_MCOMPRA = @nMaiorVda
                     
                     exec MAT021_## @nValor, @cEmissao, @nMoeda, @nMoedaForte, @nMoedaMaiDup output
                     if ( @nA1_MAIDUPL < @nMoedaMaiDup and @IN_MVPAR02 = '1' ) select @nA1_MAIDUPL = @nMoedaMaiDup
                     /* ----------------------------------------------------------------------
                        A = Pagamentos em atraso do Cliente ( A1_PAGATR )
                        B = Nro de baixas                   ( E5_TIPODOC in ( 'VL','BA', 'CP', 'LJ', 'RA','PA','V2') )
                        C = Nro de baixas canceladas        ( E5_SITUACA = 'C' )
                        D = Nro de estornos                 ( E5_TIPODOC = 'ES' )
                        A = B - ( C + D )
                        ------------------------------------------------------------------------- */
                     select @nQtdBaixas = count(*)
                       from SE5### SE5
                      where E5_FILIAL  = @cFilial_E5
                        and E5_PREFIXO = @cPrefixo
                        and E5_NUMERO  = @cNum
                        and E5_PARCELA = @cParcela
                        and E5_TIPO    = @cTipo
                        and E5_CLIFOR  = @cCliente
                        and E5_LOJA    = @cLoja
                        and E5_TIPODOC in ( 'VL','BA', 'CP', 'LJ', 'RA','PA','V2')
						and E5_SITUACA NOT IN ('C','E','X')
						and E5_TIPODOC <> 'ES'
						and NOT EXISTS (
											SELECT 0 
											FROM SE5### A 
											WHERE A.E5_FILIAL = SE5.E5_FILIAL AND 				
											A.E5_NATUREZ=SE5.E5_NATUREZ AND 
											A.E5_PREFIXO=SE5.E5_PREFIXO AND 
											A.E5_NUMERO=SE5.E5_NUMERO AND 
											A.E5_PARCELA=SE5.E5_PARCELA AND 
											A.E5_TIPO=SE5.E5_TIPO AND 
											A.E5_CLIFOR=SE5.E5_CLIFOR AND 
											A.E5_LOJA=SE5.E5_LOJA AND 
											A.E5_SEQ=SE5.E5_SEQ AND 
											A.E5_TIPODOC='ES' AND 
											A.D_E_L_E_T_= ' '
										)
                        and D_E_L_E_T_ = ' '
						                                      
                     If ( @IN_MVPAR02 = '1' and ( @cFatura = ' ' or SubString(@cFatura,1,6) = 'NOTFAT')) begin
                        /* ----------------------------------------------------------------------
                           Essa consistencia serve apenas para modulo Sigaloja(12)
                           ---------------------------------------------------------------------- */
                        If ( @IN_MODULO != 12 or @IN_MODULO != 72 ) or ( (@IN_CLIPAD != @cCliente and @IN_LOJPAD != @cLoja )) begin
                           select @nA1_NROPAG = @nA1_NROPAG + @nQtdBaixas
                        End
                     End
                     if @nSaldo = 0 
                        begin
                           If ( @cFatura = ' ' or SubString(@cFatura,1,6) = 'NOTFAT') and (( @cVencReal < @cBaixa ) and @IN_MVPAR02 = '1' ) 
                              begin
            						   exec MAT021_## @nValLiq, @cEmissao, @nMoeda, @nMoedaForte, @nValLiq output
		   	         			   select @nA1_PAGATR = @nA1_PAGATR + @nValLiq
                              End
                        end 
                     else 
                        begin
                           select @iPos1 = charindex('/' || @cTipo, @IN_TIPOCR1)
                           if @iPos1 = 0 select @iPos1 = charindex('|' || @cTipo, @IN_TIPOCR1)
                           if (( @cVencReal < @IN_DATABASE ) and @IN_MVPAR02 = '1' ) 
                              begin
                                 if @iPos1 = 0 
                                    exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nMoedaForte, @nSaldo output
            						      select @nA1_ATR = @nA1_ATR + @nSaldo
                              end
                        end
                     /* ----------------------------------------------------------------------
                        Atualiza Dados Historicos
                        ---------------------------------------------------------------------- */
                     if ( @IN_MVPAR02 = '1' ) begin
					 
                        If @cBaixa <> ' ' begin
							/* ----------------------------------------------------------------------------------
							   Tratamento para o OpenEdge
							   --------------------------------------------------------------------------------- */
							##IF_002({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })
								select @iDiferencaDATA = ( DATEDIFF ( DAY , @cVencReal, @cBaixa ) )							
							##ELSE_002
								EXEC MSDATEDIFF 'DAY', @cVencReal, @cBaixa, @iDiferencaDATA OutPut
							##ENDIF_002
						end
						
                        if @nSaldo > 0 begin
                           exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nMoedaForte, @nMSaldoAux output
                           select @nMSaldo = @nMSaldo + @nMSaldoAux
                        end 
                        
                        if ( @nA1_SALDUPM > @nA1_MSALDO )   select @nA1_MSALDO = @nA1_SALDUPM
                        else begin
                           if ( @nMSaldo > @nA1_MSALDO  )   select @nA1_MSALDO = @nMSaldo
                           else                             select @nA1_MSALDO = @nA1_MSALDO
                        end
                        
                        exec MAT021_## @nValor, @cEmissao, 1, @nMoedaForte, @nMCompra output
                        
                        If @nMCompra > @nA1_MCOMPRA select @nA1_MCOMPRA = @nMCompra
                        /* ----------------------------------------------------------
                           Somente considera compra se nao for uma fatura a receber
                           ---------------------------------------------------------- */
                        if @cOrigem != 'FINA280' begin
                           If @cPedido != ' ' begin
                              If @cPedido != @cPedAux begin
                                 select @nA1_NROCOM = @nA1_NROCOM + 1
                              end
                           end else begin
                              select @nA1_NROCOM = @nA1_NROCOM + 1
                           End
                        end
                        If ( @cFatura = ' ' or SubString(@cFatura,1,6) = 'NOTFAT') begin
                           if ( @iDiferencaDATA > @nA1_MATR )  select @nA1_MATR = @iDiferencaDATA
                           if ( @cBaixa <> ' ' and @nA1_NROPAG > 0 ) select @nA1_METR = ( @nA1_METR * ( @nA1_NROPAG - 1 ) +  @iDiferencaDATA ) / @nA1_NROPAG
                        End
                     End
                  End  -- pr
               End
               select @cPedAux = @cPedido
               /* ----------------------------------------------------------------------
                  Inicio controle de commit
                  ---------------------------------------------------------------------- */
               If @iNroRegs = 1 begin
                  Select @iNroRegs = @iNroRegs
                  Begin Tran
               End
               /* ----------------------------------------------------------------------
               Atualiza SA1
               ------------------------------------------------------------------------- */
               update SA1###
                  set A1_SALDUP  = @nA1_SALDUP,  A1_SALDUPM = @nA1_SALDUPM,
                      A1_VACUM   = @nA1_VACUM,   A1_MAIDUPL = @nA1_MAIDUPL,
                      A1_ATR     = @nA1_ATR,     A1_NROPAG  = @nA1_NROPAG,
                      A1_PAGATR  = @nA1_PAGATR,  A1_PRICOM  = @cA1_PRICOM,
                      A1_ULTCOM  = @cA1_ULTCOM,  A1_SALFIN  = @nA1_SALFIN,
                      A1_SALFINM = @nA1_SALFINM, A1_MSALDO  = @nA1_MSALDO,
                      A1_MATR    = @nA1_MATR,    A1_METR    = @nA1_METR,
                      A1_MCOMPRA = @nA1_MCOMPRA, A1_NROCOM  = @nA1_NROCOM
                where A1_FILIAL  = @cFilial_A1
                  and A1_COD     = @cCliente
                  and A1_LOJA    = @cLoja
                  and D_E_L_E_T_ = ' '
               
               If @iNroRegs >= 1024 begin
                  Commit Tran
                  select @iNroRegs = 0
               End
               SELECT @fim_CUR = 0
               fetch curSE1 into @nValor, @nSaldo,  @nValLiq,   @nVlcruz, @cCliente, @cLoja, @nMoeda, @cEmissao,
                     @cTipo,  @cVencto, @cVencReal, @cBaixa, @cPrefixo, @cNum, @cParcela, @cOrigem, @cFatura, @cMsFil, @cPedido, @cSerie
            End
            close curSE1
            deallocate curSE1
            
            If @iNroRegs > 0 begin
               select @iTranCount = 0
               Commit Tran
            End
         end
         If @cFilial_A1 = ' ' and @cFilial_E1 = ' ' begin
            select @lExecE1 = '0'
         End
      end
      /* -------------------------------------------------------------------
         Inicia a atualizacao ( RECALCULO ) SA2 e SE2 
         ------------------------------------------------------------------- */   
      if ( @IN_MVPAR01 <> '2' ) and (( @lNroExecSE2 = '0' ) or ( @cFil_E2_Ant  <> @cFilial_E2 ) or ( @cFil_A2_Ant  <> @cFilial_A2)) begin
         select @nMoedaForte = Convert(Float, @IN_MCUSTO)
         select @nValorAux  = 0
         
         If @lExecE2 = '1' begin
            select @iPos = 0
            select @iNroRegs = 0
            select @lNroExecSE2 = '1'
            /*TRATAMENTO ESPECIFICO PARA O MSSQL, POSTERIOR IMPLEMENTAÇÃO EM OUTROS BANCOS */
            ##IF_003({|| AllTrim(Upper(TcGetDB())) == "MSSQL" })
            if (@IN_SCFILTRO = '2') 
            begin
               exec F410SCFT_E2_## @cFilial_E2, @cFilial_A2, @IN_FORDE, @IN_FORATE, @nResult
            end 
            else
            ##ENDIF_003
            begin 
               declare curSE2 cursor for 
                  select E2_FORNECE, E2_LOJA, E2_SALDO, E2_MOEDA, E2_EMISSAO, E2_TIPO, E2_ORIGEM, E2_NUM, E2_PREFIXO, E2_VALOR
                  from SE2### SE2, SA2### SA2
                  where SE2.E2_FILIAL  = @cFilial_E2
                     and SA2.A2_FILIAL  = @cFilial_A2
                     and SE2.E2_FORNECE = SA2.A2_COD
                     and SE2.E2_LOJA    = SA2.A2_LOJA
                     and SA2.A2_COD     between @IN_FORDE and @IN_FORATE
                     and SE2.D_E_L_E_T_ = ' '
                     and SA2.D_E_L_E_T_ = ' '
            end
            open curSE2
            fetch curSE2 into @cFornece, @cLoja, @nSaldo, @nMoeda, @cEmissao, @cTipo, @cOrigem, @cNum, @cPrefixo, @nValor
            
            while @@fetch_status = 0 begin
               select @iNroRegs = @iNroRegs + 1
               /* ----------------------------------------------------------------------
                  Atualiza Dados Historicos
                  ---------------------------------------------------------------------- */
               if ( @IN_MVPAR02 = '1' ) begin
                  select @nA2_SALDUP = A2_SALDUP, @nA2_SALDUPM = A2_SALDUPM, @cA2_PRICOM = A2_PRICOM,
                         @cA2_ULTCOM = A2_ULTCOM, @nA2_MCOMPRA = A2_MCOMPRA, @nA2_MNOTA  = A2_MNOTA ,
                         @nA2_NROCOM = A2_NROCOM, @nA2_MSALDO  = A2_MSALDO
                    from SA2###
                   where A2_FILIAL  = @cFilial_A2
                     and A2_COD     = @cFornece
                     and A2_LOJA    = @cLoja
                     and D_E_L_E_T_ = ' '
               end else begin
                  select @nA2_SALDUP = A2_SALDUP, @nA2_SALDUPM = A2_SALDUPM, @cA2_PRICOM = A2_PRICOM,
                         @cA2_ULTCOM = A2_ULTCOM, @nA2_MCOMPRA = A2_MCOMPRA, @nA2_MNOTA  = A2_MNOTA
                    from SA2###
                   where A2_FILIAL  = @cFilial_A2
                     and A2_COD     = @cFornece
                     and A2_LOJA    = @cLoja
                     and D_E_L_E_T_ = ' '
               end
                  
               select @nMoedaSalDup = 0
               select @nMoedaSalDupM = 0
               select @nValorAux     = 0
               /* -------------------------------------------------------------------------------
                  VERIFICA SE @cTipo (E2_TIPO) ESTÁ EM @IN_TIPOCP - SUBTRAIO
                  ------------------------------------------------------------------------------- */ 
               select @iPos = Charindex('/' || @cTipo,@IN_TIPOCP)
               if @iPos > 0 begin
                  select @nAux = 1
                  exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nAux, @nMoedaSalDup output
                  exec MAT021_## @nSaldo, @cEmissao, @nMoeda, @nMoedaForte, @nMoedaSalDupM output
                  select @nA2_SALDUP  = @nA2_SALDUP  - @nMoedaSalDup
                  select @nA2_SALDUPM = @nA2_SALDUPM - @nMoedaSalDupM
                  select @nAux = 1
                  exec MAT021_## @nValor, @cEmissao, @nAux, @nMoedaForte, @nValorAux output
                  If @nA2_MCOMPRA < @nValorAux select @nA2_MCOMPRA = @nValorAux
               end else begin
                  select @nSaldoTit = @nSaldo
                  select @nAux = 1
                  exec MAT021_## @nSaldoTit, @cEmissao, @nMoeda, @nAux, @nMoedaSalDup output
                  exec MAT021_## @nSaldoTit, @cEmissao, @nMoeda, @nMoedaForte, @nMoedaSalDupM output
                  select @nA2_SALDUP  = @nA2_SALDUP  + @nMoedaSalDup
                  select @nA2_SALDUPM = @nA2_SALDUPM + @nMoedaSalDupM
                  if @cA2_PRICOM > @cEmissao OR @cA2_PRICOM is null select @cA2_PRICOM = @cEmissao
                  if @cA2_ULTCOM < @cEmissao OR @cA2_ULTCOM is null select @cA2_ULTCOM = @cEmissao
                  select @nAux = 1
                  exec MAT021_## @nValor, @cEmissao, @nAux, @nMoedaForte, @nValorAux output
                  If @nA2_MCOMPRA < @nValorAux select @nA2_MCOMPRA = @nValorAux
                  if ( @IN_MVPAR02 = '1' ) begin
                     if ( @cOrigem <> 'FINA290' )      select @nA2_NROCOM = @nA2_NROCOM + 1
                     if ( @nA2_SALDUPM > @nA2_MSALDO ) select @nA2_MSALDO = @nA2_SALDUPM
                  end
               end
               
               If Substring( @cOrigem, 1, 3 ) = 'FIN' begin
                  If @nA2_MNOTA < @nValorAux select @nA2_MNOTA = @nValorAux
               end else begin
                  Select @nF1_VALBRUT = F1_VALBRUT, @cF1_EMISSAO = F1_EMISSAO
                    From SF1###
                   Where F1_FILIAL  = @cFilial_F1
                     and F1_DUPL    = @cNum
                     and F1_PREFIXO = @cPrefixo
                     and F1_FORNECE = @cFornece
                     and F1_LOJA    = @cLoja
                     and D_E_L_E_T_ = ' '
                  
                  select @nAux = 1
                  exec MAT021_## @nF1_VALBRUT, @cF1_EMISSAO, @nAux, @nMoedaForte, @nValorAux output
                  If @nA2_MNOTA < @nValorAux select @nA2_MNOTA = @nValorAux
               End
               /* -------------------------------------------------------------------------------
                  Controle de commits
                  ------------------------------------------------------------------------------- */
               If @iNroRegs = 1 begin
                  Select @iNroRegs = @iNroRegs
                  Begin Tran
               End
               
               if ( @IN_MVPAR02 = '1' ) begin
                  update SA2###
                     set A2_SALDUP  = @nA2_SALDUP, A2_SALDUPM = @nA2_SALDUPM,  A2_PRICOM  = @cA2_PRICOM,
                         A2_ULTCOM  = @cA2_ULTCOM, A2_MCOMPRA = @nA2_MCOMPRA,  A2_MNOTA   = @nA2_MNOTA ,
                         A2_NROCOM  = @nA2_NROCOM, A2_MSALDO  = @nA2_MSALDO
                   where A2_FILIAL  = @cFilial_A2
                     and A2_COD     = @cFornece
                     and A2_LOJA    = @cLoja
                     and D_E_L_E_T_ = ' '
               end else begin
                  update SA2###
                     set A2_SALDUP  = @nA2_SALDUP, A2_SALDUPM = @nA2_SALDUPM,  A2_PRICOM  = @cA2_PRICOM,
                         A2_ULTCOM  = @cA2_ULTCOM, A2_MCOMPRA = @nA2_MCOMPRA,  A2_MNOTA   = @nA2_MNOTA
                   where A2_FILIAL  = @cFilial_A2
                     and A2_COD     = @cFornece
                     and A2_LOJA    = @cLoja
                     and D_E_L_E_T_ = ' '
               end
               If @iNroRegs >= 1024 begin
                  Commit Tran
                  select @iNroRegs = 0
               End
               SELECT @fim_CUR = 0
               fetch curSE2 into @cFornece, @cLoja, @nSaldo, @nMoeda, @cEmissao, @cTipo, @cOrigem, @cNum, @cPrefixo, @nValor
            End
            close curSE2
            deallocate curSE2
            
            If @iNroRegs > 0 begin
               select @iTranCount = 0
               Commit Tran
            End
         end
         If @cFilial_A2 = ' ' and @cFilial_E2 = ' ' begin
            select @lExecE2 = '0'
         End
      End
      /* -------------------------------------------------------------------
         Salva as filiais anteriores
         ------------------------------------------------------------------- */
      select @cFil_A1_Ant = @cFilial_A1
      select @cFil_A2_Ant = @cFilial_A2
      select @cFil_E1_Ant = @cFilial_E1
      select @cFil_E2_Ant = @cFilial_E2

	  select @nFil = @nFil + 1
   End  --While
   select @OUT_RESULTADO = '1'
end