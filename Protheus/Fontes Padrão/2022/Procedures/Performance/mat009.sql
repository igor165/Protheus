Create procedure MAT009_##
 (
   @IN_ALIAS      char(03),
   @IN_ORDEM      char(03),
   @IN_RECFILE    integer,
   @IN_NRECRE5    integer,
   @IN_NRECTRB    integer,
   @IN_MV_PAR14   integer,
   @IN_MV_PAR1    char(08),
   @IN_MV_PRODPR0 integer,
   @IN_FILIALCOR  char('B1_FILIAL'),
   @IN_RECNOSMO   integer,
   @IN_CTRANSF    char(01),
   @IN_CPAISLOC   Char(03),
   @IN_USAFILTRF  Char(01),
   @IN_SEQ500     Char(01),
   @IN_MV_PRODMOD Char(01),
   @IN_MV_CQ      Char('B2_LOCAL'),
   @IN_MV_PAR11   integer,
   @IN_MV_PAR18   integer,
   @IN_MV_330JCM1 Char(05),
   @IN_MV_PROCQE6 Char(01),
   @cB1_CCCUSTO   Char(01),
   @IN_FILIALPROC char('B1_FILIAL')
 )

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    -----------------------------------------------------------------------------------------------------------------
    Programa    :   <s> A330TRB </s>
    -----------------------------------------------------------------------------------------------------------------
    Assinatura  :   <a> 007 </a>
    -----------------------------------------------------------------------------------------------------------------
    Descricao   :   <d> Grava arquivo de trabalho por nivel da estrutura </d>
    -----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_ALIAS        - Alias do Arquivos onde será efetuado os selects (SD1, SD2, SD3)
                        @IN_ORDEM        - Ordem Calculo
                        @IN_RECFILE      - Nº do recno posicionado no alias passado como parametro
                        @IN_NRECRE5      - Recno do SD3
                        @IN_NRECTRB      - Recno do Arquivo de Trabalho
                        @IN_MV_PAR14     - Tipo de Processamento
                        @IN_MV_PAR1      - Data limite para processamento
                        @IN_MV_PRODPR0   -
						@IN_FILIALCOR  char('B1_FILIAL'),
						@IN_RECNOSMO   integer,
						@IN_CTRANSF    char(01),
						@IN_CPAISLOC   Char(03),
						@IN_USAFILTRF  Char(01),
						@IN_SEQ500     Char(01),
						@IN_MV_PRODMOD Char(01),
						@IN_MV_CQ       - Parâmetro MV_CQ
						@IN_MV_PAR11    - Gera estrutura pela movimentação
						@IN_MV_PAR18    - Método de apropriação: 1-Sequencial; 2-Diário; 3-Mensal
						@IN_MV_330JCM1	- Parâmetro MV_M330JCM1
						@IN_MV_PROCQE6  - Parâmetro MV_PROCQE6
                    </ri>
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Ricardo Gonçalves </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 19/06/2002 </dt>
    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração, automática, de documentação.
--------------------------------------------------------------------------------------------------------------------- */
Declare @cTRB_NIVEL   varchar(03)
Declare @cTRB_NIVSD3  char(01)
Declare @cBKP_NIVSD3  char(01)
Declare @cTRB_COD     char('B1_COD')
Declare @cTRB_LOCAL   char('B1_LOCPAD')
Declare @cTRB_CHAVE   varchar('D3_OP+D1_FORNECE+D3_DOC+D2_SERIE+D3_NUMSEQ+D1_DTDIGIT+D3_CF+D3_NIVEL')
Declare @cTRB_OP      char('D3_OP')
Declare @cTRB_CF      char('D3_CF')
Declare @cTRB_CFAUX   char('D3_CF')
Declare @cTRB_SEQ     char('D3_NUMSEQ')
Declare @cTRB_SEQPRO  char('D3_NUMSEQ')
Declare @cTRB_TES     char('F4_CODIGO')
Declare @dTRB_DTORIG  char( 08 )
Declare @nTRB_RECSD1  integer
Declare @cTRB_DOC     char('D3_DOC;D2_DOC;D1_DOC')
Declare @cTRB_TIPO    char(01)
Declare @cTRB_TIPONF  char('D1_TIPO')
Declare @nTRB_QUANT   float
Declare @cOPVAZIA     char('D3_OP')
Declare @nTRX_QUANT   float
Declare @nTRX_QPERDA  float
Declare @dTRB_DTBASE  char(08)
Declare @cTRB_LOJA    char('D1_LOJA;D2_LOJA')

Declare @cD3_ESTORNO char('D3_ESTORNO')
Declare @cTRB_CLI    char('D2_CLIENTE')
Declare @cTRB_SERIE  char('D2_SERIE')

Declare @lGrava      char(01)
Declare @cOrdem      char(03)
declare @cExecutou   char(01)
declare @cAlias      char(03)
Declare @dDtBusca    char(08)
Declare @iContador   integer

Declare @cD1_FORNECE	 char('D1_FORNECE')
Declare @cAliasAux	 char(03)
Declare @cRetFil		 char('B1_FILIAL')
Declare @cTRB_ESPECIE char(5)
Declare @cTRB_TIPODOC char(2)
Declare @cTRB_FILTRA	 char(1)
Declare @cTRB_ITEM    char('D1_ITEM')
Declare @cTRB_MOD     char(1)

Declare @cAux Char(3)
Declare @nAux Integer
Declare @nBypass Integer
Declare @cNumSeq Char('D3_NUMSEQ')
Declare @cPrCQE6 Char(2)
Declare @cNPrCQE6 Char(2)
Declare @cFil_SF4 Char('F4_FILIAL')
Declare @cFil_SG1 Char('G1_FILIAL')
Declare @cFil_SC2 Char('C2_FILIAL')
Declare @cFil_SD3 Char('D3_FILIAL')
Declare @cFil_SD7 Char('D7_FILIAL')
Declare @F4Estoque Char(1)
Declare @F4Poder3 Char(1)
Declare @D7OrigLan Char(2)
Declare @G1Niv Char(2)
Declare @G1NivComp Char(2)

Declare @cOldORDEM Char(03)
Declare @cOldTRB_NIVEL Char(03)
Declare @cOldTRB_NIVSD3 Char(01)
Declare @cOldTRB_TIPO Char(01)
Declare @cOldTRB_CF Char('D3_CF')
Declare @cOldTRB_CHAVE varchar('D3_OP+D1_FORNECE+D3_DOC+D2_SERIE+D3_NUMSEQ+D1_DTDIGIT+D3_CF+D3_NIVEL') /* Tamanho do campo TRB_CHAVE da tabela TRBT1SP */
Declare @cTRB_CHAVEREAD varchar('D3_OP+D1_FORNECE+D3_DOC+D2_SERIE+D3_NUMSEQ+D1_DTDIGIT+D3_CF+D3_NIVEL') /* Tamanho do campo TRB_CHAVE da tabela TRBT1SP */

Declare @nRECFILE integer
Declare @cFILIALCOR char('B1_FILIAL')
Declare @cFILIALPROC char('B1_FILIAL')
Declare @cNRECRE5 integer
Declare @nNRECTRB integer
Declare @cFil_SB1 Char('B1_FILIAL')
Declare @cD3CF Char('D3_CF')
Declare @cD3OP Char('D3_OP')
Declare @cD3EMI Char('D3_EMISSAO')
Declare @cD3SEQ Char('D3_NUMSEQ')
Declare @cD7SEQ Char('D7_NUMSEQ')

begin
   /* ------------------------------------------------------------------------------------------------------------------
      Inicializando Variaveis
   ------------------------------------------------------------------------------------------------------------------ */
   select @lGrava      = '0'
   select @cTRB_NIVEL  = '  '
   select @cTRB_NIVSD3 = ' '
   select @cBKP_NIVSD3 = ' '
   select @cTRB_COD    = ' '
   select @cTRB_LOCAL  = ' '
   select @cTRB_CHAVE  = ' '
   select @cTRB_OP     = ' '
   select @cTRB_CF     = ' '
   select @cTRB_CFAUX  = ' '
   select @cTRB_SEQ    = ' '
   select @cTRB_SEQPRO = ' '
   select @dTRB_DTORIG = ' '
   select @nTRB_RECSD1 = 0
   select @cTRB_TES    = ' '
   select @cTRB_DOC    = ' '
   select @cTRB_TIPO   = ' '
   select @cTRB_TIPONF = ' '
   Select @cOPVAZIA    = '   '
   Select @nTRX_QUANT  = 0
   Select @nTRX_QPERDA = 0
   select @cExecutou   = '0'
   select @cTRB_CLI    = ' '
   select @cTRB_SERIE  = ' '
   select @nTRB_QUANT  = 0
   select @cRetFil     = ' '
   select @cTRB_LOJA    = ' '
   select @cTRB_ESPECIE = '     '
   select @cTRB_TIPODOC = '  '
   select @cTRB_FILTRA  = ' '
   select @cTRB_ITEM  = '    '
   select @cTRB_MOD = ' '
   select @G1Niv = '  '
   select @G1NivComp = '  '
   select @nAux = 0
   select @nBypass = 0

   select @cOldORDEM = '   '
   select @cOldTRB_NIVEL  = '   '
   select @cOldTRB_NIVSD3 = ' '
   select @cOldTRB_TIPO = ' '
   select @cOldTRB_CHAVE = ' '
   select @cTRB_CHAVEREAD = ' '

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @nRECFILE = @IN_RECFILE
   select @cFILIALCOR = @IN_FILIALCOR
   select @cFILIALPROC = @IN_FILIALPROC
   select @cNRECRE5 = @IN_NRECRE5
   select @nNRECTRB = @IN_NRECTRB

   /* -------------------------------------------------------------------------
    Testa se existe ponto de entrada e executa-o
   ------------------------------------------------------------------------- */
   select @cAlias    = ' '
   select @cOrdem    = ' '
   select @cExecutou = ' '

   select @cAux  = 'SB1'
   exec XFILIAL_## @cAux , @cFILIALCOR , @cFil_SB1 output
   select @cAux  = 'SF4'
   exec XFILIAL_## @cAux , @cFILIALCOR , @cFil_SF4 output
   select @cAux  = 'SC2'
   exec XFILIAL_## @cAux , @cFILIALCOR , @cFil_SC2 output
   select @cAux  = 'SD3'
   exec XFILIAL_## @cAux , @cFILIALCOR , @cFil_SD3 output
   select @cAux  = 'SD7'
   exec XFILIAL_## @cAux , @cFILIALCOR , @cFil_SD7 output
   if @IN_MV_PAR11 = 1	select @cFil_SG1 = ' '
   else begin
      select @cAux  = 'SG1'
      exec XFILIAL_## @cAux , @cFILIALCOR , @cFil_SG1 output
   end

   exec MA330SEQ_## @IN_ORDEM, @IN_ALIAS, @nRECFILE, @cOrdem output, @cAlias output, @cExecutou output

   if ( @cExecutou = '1' ) begin

      /* ---------------------------------------------------------------------------------------------------------------
         Preparando valores para serem inseridos no trb cujo alias = 'SD1'
      --------------------------------------------------------------------------------------------------------------- */
      if @cAlias = 'SD1' begin
         select @lGrava = '1'
         select @cTRB_COD   = D1_COD  , @cTRB_LOCAL = D1_LOCAL , @cTRB_SEQ  = D1_NUMSEQ  , @dTRB_DTORIG  = D1_DTDIGIT,
                @cTRB_TES   = D1_TES   , @cTRB_DOC   = D1_DOC   , @cTRB_TIPONF = D1_TIPO  , @cD1_FORNECE  = D1_FORNECE,
                @cTRB_SERIE = D1_SERIE , @nTRB_QUANT = D1_QUANT , @cTRB_LOJA = D1_LOJA    , @cTRB_OP      = D1_OP,
                @cTRB_ITEM = D1_ITEM
                ##FIELDP01( 'SD1.D1_ESPECIE;D1_TIPODOC' )
                , @cTRB_ESPECIE = D1_ESPECIE , @cTRB_TIPODOC = D1_TIPODOC
                ##ENDFIELDP01
         from SD1### (nolock)
         where R_E_C_N_O_ = @nRECFILE

         select @cAliasAux = 'SD1'
         exec MAT047_## @cFILIALCOR , @cAliasAux , @cTRB_TES , @cTRB_ESPECIE , @cTRB_TIPODOC , @IN_CPAISLOC , @cTRB_DOC , @cTRB_SERIE , @cD1_FORNECE , @cTRB_LOJA , @IN_USAFILTRF, @cRetFil output

         if (@IN_MV_PAR14 = 1) select @cTRB_SEQPRO = @cTRB_SEQ

         if @cOrdem = '300' begin
            select @cTRB_CHAVE = (@cOPVAZIA||'E'||@dTRB_DTORIG||@cTRB_SEQ||'9y')

            /* Acerta os niveis do SD1 quando gerou RE5 de produto com estrutura */
            select @F4Estoque = F4_ESTOQUE, @F4Poder3 = F4_PODER3
            from SF4### (nolock)
            where D_E_L_E_T_  = ' ' and F4_FILIAL = @cFil_SF4 and F4_CODIGO = @cTRB_TES

            if (@F4Estoque = 'S' and @F4Poder3 = 'D') begin
               if @cTRB_NIVEL = '  ' begin
                  if @IN_MV_PAR11  = 1 begin
                     select @G1Niv = isnull(min(G1_NIV),'  ')
                     from TRB###SG1
                     where G1_FILIAL  = @cFil_SG1  and G1_COD  = @cTRB_COD  and G1_FILPROC  = @cFILIALPROC and D_E_L_E_T_  = ' '
                  end
                  else begin
                     select @G1Niv = isnull(min(G1_NIV),'  ')
                     from SG1### (nolock)
                     where G1_FILIAL  = @cFil_SG1  and G1_COD  = @cTRB_COD and D_E_L_E_T_  = ' '
                  end
                  if @G1Niv <> '  ' begin
                     select @cTRB_NIVEL = convert(char(2),100 - convert(integer,@G1Niv))
                  end
               end
               select @cTRB_NIVSD3 = '5'
               if @cTRB_OP <> @cOPVAZIA begin
                  select @cTRB_NIVEL = isnull(C2_NIVEL,'  ')
                  from SC2### (nolock)
                  where D_E_L_E_T_ = ' '
                  and C2_FILIAL    = @cFil_SC2
                  and C2_NUM       = Substring( @cTRB_OP, 01, 6 )
                  and C2_ITEM      = Substring( @cTRB_OP, 07, 2 )
                  and C2_SEQUEN    = Substring( @cTRB_OP, 09, 3 )
                  and C2_ITEMGRD   = Substring( @cTRB_OP, 12, 3 )
                  select @cD3OP = D3_OP, @cD3CF = D3_CF, @cD3EMI = D3_EMISSAO, @cD3SEQ = D3_NUMSEQ
                  from SD3###
                  where R_E_C_N_O_ = @cNRECRE5

                  select @cTRB_CHAVE = (@cD3OP||substring(@cD3CF,2,1)||@dTRB_DTORIG||@cTRB_SEQ)

                  if @cD3CF in ('DE4','DE6','DE7') select @cTRB_CHAVE = (@cTRB_CHAVE||'9y')
                  else                             select @cTRB_CHAVE = (@cTRB_CHAVE||'0y')
               end else	select @cTRB_NIVEL = (@cTRB_NIVEL||'y')
            end
         end else begin
            if @cOrdem = '500' and @IN_SEQ500 = '1' begin
               select @cTRB_CHAVE = (@cTRB_SEQ||@cD1_FORNECE||@dTRB_DTORIG||@cTRB_DOC||@cTRB_SERIE)
            end else begin
               select @cTRB_CHAVE = (@cD1_FORNECE||@dTRB_DTORIG||@cTRB_SEQ||@cTRB_DOC||@cTRB_SERIE)
            end
         end

      end

      /* ---------------------------------------------------------------------------------------------------------------
         Preparando valores para serem inseridos no trb cujo alias = 'SD2'
      --------------------------------------------------------------------------------------------------------------- */
      if @cAlias = 'SD2' begin
         select @lGrava = '1'

         select @cTRB_COD   = D2_COD     , @cTRB_LOCAL   = D2_LOCAL  , @cTRB_SEQ  = D2_NUMSEQ  , @dTRB_DTORIG = D2_EMISSAO ,
                @cTRB_TES   = D2_TES     , @cTRB_DOC     = D2_DOC    , @cTRB_CLI  = D2_CLIENTE , @cTRB_SERIE  = D2_SERIE   ,
                @nTRB_QUANT = D2_QUANT   , @cTRB_LOJA    = D2_LOJA	, @cTRB_ITEM = D2_ITEM
                ##FIELDP02( 'SD2.D2_ESPECIE;D2_TIPODOC' )
                  ,@cTRB_ESPECIE = D2_ESPECIE , @cTRB_TIPODOC = D2_TIPODOC
                ##ENDFIELDP02
         from SD2### (nolock)
         where R_E_C_N_O_ = @nRECFILE

         select @cAliasAux = 'SD2'
         exec MAT047_## @cFILIALCOR , @cAliasAux , @cTRB_TES , @cTRB_ESPECIE , @cTRB_TIPODOC , @IN_CPAISLOC , @cTRB_DOC , @cTRB_SERIE , @cTRB_CLI , @cTRB_LOJA , @IN_USAFILTRF, @cRetFil output
         if (@IN_MV_PAR14 = 1) select @cTRB_SEQPRO = @cTRB_SEQ

         if @cOrdem <> '300' begin
            if @cOrdem = '500' and @IN_SEQ500 = '1' begin
               select @cTRB_CHAVE = (@cTRB_SEQ||@cTRB_CLI||@dTRB_DTORIG||@cTRB_DOC||@cTRB_SERIE)
            end else begin
                select @cTRB_CHAVE = (@cTRB_CLI||@dTRB_DTORIG||@cTRB_SEQ||@cTRB_DOC||@cTRB_SERIE)
            end
         end else begin
            select @cTRB_CHAVE = (@cOPVAZIA||'E'||@dTRB_DTORIG||@cTRB_SEQ||'9x')
         end

         /* Acerta os niveis do SD2 de REMESSA de produto com estrutura */
         if @cOrdem = '300' or @cRetFil <> ' ' begin
            select @F4Estoque = ' '
            select @F4Poder3 = ' '

            if @cRetFil = ' '    select @F4Estoque = F4_ESTOQUE, @F4Poder3 = F4_PODER3
                                 from SF4### (nolock)
                                 where D_E_L_E_T_  = ' ' and F4_FILIAL = @cFil_SF4 and F4_CODIGO = @cTRB_TES

            if @cRetFil <> ' ' or (@F4Estoque = 'S' and @F4Poder3 = 'R') begin
			   select @G1Niv = '  '
               if @IN_MV_PAR11 = 1 begin
				  /* procura o nivel por produto produzido*/
                  select @G1Niv = isnull(min(G1_NIV), '  ')
                  from TRB###SG1
                  where (D_E_L_E_T_ = ' ' and G1_FILIAL = @cFil_SG1 and G1_COD = @cTRB_COD and G1_FILPROC = @cFILIALPROC)

				  /* procura o nivel por componente do produto produzido*/
				  select @G1NivComp = isnull(min(G1_NIV), '  ')
				  from TRB###SG1
				  where (D_E_L_E_T_ = ' ' and G1_FILIAL = @cFil_SG1 and G1_COMP = @cTRB_COD and G1_FILPROC = @cFILIALPROC)
               end else begin
				  /* procura o nivel por produto produzido*/
                  select @G1Niv = isnull(min(G1_NIV), '  ')
                  from SG1###
                  where D_E_L_E_T_ = ' ' and G1_FILIAL = @cFil_SG1 and G1_COD = @cTRB_COD
				  /* procura o nivel por componente do produto produzido*/
                  select @G1NivComp = isnull(min(G1_NIV), '  ')
                  from SG1###
                  where D_E_L_E_T_ = ' ' and G1_FILIAL = @cFil_SG1 and G1_COMP = @cTRB_COD

               end

			   if (@G1NivComp is null) select @G1NivComp = ' ' /* se não encontrar o produto como componente, o nivel fica em branco */
			   if (@G1Niv is null) select @G1Niv = ' ' /*se não encontrar o produto como produto produzido, o nivel fica em branco */
               if @G1Niv <> '  '	select @cTRB_NIVEL = convert(char(2),100 - convert(integer,@G1Niv))

               select @cTRB_NIVSD3 = '5'
               select @cTRB_NIVEL = (@cTRB_NIVEL||'x')
            end
         end
      end

      /* ---------------------------------------------------------------------------------------------------------------
         Preparando valores para serem inseridos no trb cujo alias = 'SD3'
      --------------------------------------------------------------------------------------------------------------- */
      if @cAlias = 'SD3' begin
         select @lGrava = '1'

         select @cTRB_COD    = D3_COD,     @cTRB_LOCAL  = D3_LOCAL, @cTRB_SEQ   = D3_NUMSEQ, @dTRB_DTORIG = D3_EMISSAO,
                @cTRB_DOC    = D3_DOC,     @cTRB_CF     = D3_CF,    @cTRB_OP    = D3_OP,
                @cD3_ESTORNO = D3_ESTORNO, @nTRX_QPERDA = D3_PERDA, @nTRB_QUANT = D3_QUANT
         from SD3### SD3 (nolock)
         where SD3.R_E_C_N_O_ = @nRECFILE

         SELECT @nTRX_QUANT  = @nTRB_QUANT

         if (@IN_MV_PAR14 = 1) select @cTRB_SEQPRO = @cTRB_SEQ

         select @cTRB_CHAVE = (@cTRB_OP||substring(@cTRB_CF,2,1)||@dTRB_DTORIG||@cTRB_SEQ||@IN_CTRANSF)

         if @cTRB_CF in ( 'DE4', 'DE6', 'DE7' ) select @cTRB_CHAVE = (@cTRB_CHAVE||'9')
         else                                   select @cTRB_CHAVE = (@cTRB_CHAVE||'0')

         if @cNRECRE5 > 0 begin
            select @cD1_FORNECE = D1_FORNECE, @cTRB_DOC = D1_DOC, @cTRB_SERIE = D1_SERIE, @cD3SEQ = D1_NUMSEQ, @dTRB_DTORIG = D1_DTDIGIT, @cTRB_ITEM = D1_ITEM
            from SD1### (nolock)
            where R_E_C_N_O_ = @cNRECRE5

            if @cOrdem = '300' begin
               select @cTRB_CHAVE = (@cOPVAZIA||'E'||@dTRB_DTORIG||@cD3SEQ||'9z')
            end else begin
               select @cTRB_CHAVE = (@cD1_FORNECE||@dTRB_DTORIG||@cD3SEQ||@cTRB_DOC||@cTRB_SERIE||'z')
            end
         end

         /* ------------------------------------------------------------------------------------------------------------
            No caso das producoes grava arquivo de apontamentos p/ ratear custo no caso de apontamentos em
            locais diferentes
         ------------------------------------------------------------------------------------------------------------ */
         if (@cTRB_CF in ( 'PR0', 'PR1' )) and  (@cD3_ESTORNO <> 'S') begin

            if ( @IN_MV_PAR14 <> 3 ) begin
               select @dDtBusca = @IN_MV_PAR1

               select @iContador = Count(*)
               from TRX### TRX
               where TRX_FILIAL = @cFILIALCOR
                  and TRX_DATA   = @dDtBusca
                  and TRX_OP     = @cTRB_OP
                  and TRX_COD    = @cTRB_COD
                  and TRX_LOCAL  = @cTRB_LOCAL
            end else begin
               select @dDtBusca = @dTRB_DTORIG

               select @iContador = Count(*)
               from TRX### TRX
               where TRX_FILIAL = @cFILIALCOR
                  and TRX_DATA   = @dDtBusca
                  and TRX_OP     = @cTRB_OP
                  and TRX_COD    = @cTRB_COD
                  and TRX_LOCAL  = @cTRB_LOCAL
            end

            if @iContador is null select @iContador = 0

            if ( @iContador > 0 ) begin
               update TRX### set TRX_QUANT = TRX_QUANT + @nTRX_QUANT, TRX_QPERDA = TRX_QPERDA + @nTRX_QPERDA
               where TRX_FILIAL = @cFILIALCOR
                  and TRX_DATA   = @dDtBusca
                  and TRX_OP     = @cTRB_OP
                  and TRX_COD    = @cTRB_COD
                  and TRX_LOCAL  = @cTRB_LOCAL

            end else begin
               insert into TRX### (TRX_FILIAL ,  TRX_COD,   TRX_DATA,  TRX_OP,   TRX_LOCAL,    TRX_QUANT,   TRX_QPERDA)
               values        	    (@cFILIALCOR, @cTRB_COD, @dDtBusca, @cTRB_OP, @cTRB_LOCAL, @nTRX_QUANT, @nTRX_QPERDA)
            end
         end

         /* Ajuste de nivel, nivsd3 e chave baseado nos niveis de estrutura */
		 if @cTRB_CF = 'DE0' and @cTRB_OP <> ' ' begin
			select @nBypass = 1
		 end
		 if @nBypass = 0 and @cTRB_OP <> ' ' and substring(@cTRB_CF,2,2) <> 'E3' and (@cTRB_CF <> 'RE5' or @cOrdem = '300') begin

			/* Quando for RE5 somente alterar a chave quando a nota de entrada ('SD1') estiver com a TES configurada com F4_ESTOQUE ='S' e F4_PODER3 == 'D' */
			if @cTRB_CF = 'RE5' and @cOrdem = '300' begin
				select @cTRB_NIVEL  = '  '
				select @cTRB_NIVSD3 = ' '
				if @cNRECRE5 >0 begin
					select @cTRB_TES = D1_TES
					from SD1###
					where R_E_C_N_O_ = @cNRECRE5

					select @F4Estoque = F4_ESTOQUE, @F4Poder3 = F4_PODER3
					from SF4### (nolock)
					where D_E_L_E_T_  = ' ' and F4_FILIAL = @cFil_SF4 and F4_CODIGO = @cTRB_TES

					select @cTRB_TES = ' '

					if @F4Estoque = 'S' and @F4Poder3 = 'D' begin
						select @cTRB_CHAVE = (@cTRB_OP||substring(@cTRB_CF,2,1)||@dTRB_DTORIG||@cD3SEQ)
						if @cTRB_CF in ('DE4','DE6','DE7')  select @cTRB_CHAVE = (@cTRB_CHAVE||'9z')
							else
							begin
							select @cTRB_CHAVE = (@cTRB_CHAVE||'0z')
							select @cTRB_NIVEL  = C2_NIVEL
							from SC2### (nolock)
							where D_E_L_E_T_  = ' '  and C2_FILIAL  = @cFil_SC2  and C2_NUM  = substring ( @cTRB_OP , 01 , 6 ) and C2_ITEM  = substring ( @cTRB_OP ,
								07 , 2 ) and C2_SEQUEN  = substring ( @cTRB_OP , 09 , 3 ) and C2_ITEMGRD  = substring ( @cTRB_OP ,
								12 , 3 )
							select @cTRB_NIVSD3  = '5'
						end
					end
				end
			end else begin
				select @cTRB_NIVEL = C2_NIVEL
				from SC2### (nolock)
				where D_E_L_E_T_ = ' '
				and C2_FILIAL    = @cFil_SC2
				and C2_NUM       = Substring( @cTRB_OP, 01, 6 )
				and C2_ITEM      = Substring( @cTRB_OP, 07, 2 )
				and C2_SEQUEN    = Substring( @cTRB_OP, 09, 3 )
				and C2_ITEMGRD   = Substring( @cTRB_OP, 12, 3 )

				select @cTRB_NIVSD3 = '5'
			end

			end else if (substring(@cTRB_CF,2,2) in ('E4','E7')) or ((substring(@cTRB_CF,2,2) = 'E6') and (@cTRB_LOCAL = @IN_MV_CQ)) begin
			/*Verifica se o produto da transferencia tem estrutura: inicio do trecho corresponde a função A330Estru*/
			if @cTRB_CF in ('RE4','RE7','RE6') begin
				if @IN_MV_PROCQE6 = '1' begin
					select @cPrCQE6 = 'E4'
					select @cNPrCQE6 = 'E6'
				end else begin
					select @cPrCQE6 = 'E6'
					select @cNPrCQE6 = 'E4'
				end
				select @cAux = ' '
				select @D7OrigLan = ' '
				select @cTRB_NIVSD3 = '5'

				/* Ajusta CF se grava mov. do CQ atraves de producao com RE6/DE6 */
				if @cTRB_LOCAL = @IN_MV_CQ begin
					select @D7OrigLan = isnull(D7_ORIGLAN,' ')
					from SD7###
					where D_E_L_E_T_ = ' ' and D7_FILIAL = @cFil_SD7 and D7_PRODUTO = @cTRB_COD and
						D7_NUMSEQ = @cTRB_SEQ and D7_NUMERO = substring(@cTRB_DOC,1,len(D7_NUMERO))

					if @D7OrigLan = "PR" begin
						if substring(@cTRB_CF,2,2) = @cPrCQE6 begin
						update SD3### set D3_CF  =  (''||substring(D3_CF,1,1)||@cNPrCQE6) where R_E_C_N_O_ = @nRECFILE
						select @cTRB_CF = (''||substring(@cTRB_CF,1,1)||@cNPrCQE6)
						select @cNPrCQE6 = ' ' /* servirá de flag para saber que atualizou CF*/
						end
					end else if @D7OrigLan <> ' ' begin
						If @cTRB_CF in ('RE6') begin
							Select @cD7SEQ = D7_NUMSEQ 
							From SD7###
							Where D7_FILIAL = @cFILIALCOR and D7_NUMERO = substring(@cTRB_DOC,1,len(D7_NUMERO)) and
								  D7_PRODUTO = @cTRB_COD and D7_LOCAL = @cTRB_LOCAL and D7_TIPO = 0
							select @cAux = isnull(TRB_NIVEL,' ')
						    from TRB###
						    where D_E_L_E_T_ = ' ' and TRB_FILIAL = @cFILIALCOR and TRB_ALIAS = 'SD3' and TRB_ORDEM <> '100' and
							TRB_LOCAL = @cTRB_LOCAL and TRB_SEQ = @cD7SEQ and  Not(TRB_CF in ('DE6') and TRB_LOCAL = @IN_MV_CQ)
							Group by TRB_NIVEL
						end else begin
							select @cAux = isnull(TRB_NIVEL,' ')
							from TRB###
							where D_E_L_E_T_ = ' ' and TRB_FILIAL = @cFILIALCOR and TRB_ALIAS = 'SD1' and TRB_SEQ = @cTRB_SEQ and TRB_ORDEM <> '100'

							if @cAux is null select @cAux = ' '
						end
					end
				end

				if @IN_MV_PAR11 = 1  select @G1Niv = isnull(min(G1_NIV), '  ') from TRB###SG1 where (D_E_L_E_T_ = ' ' and G1_FILPROC = @cFILIALPROC and G1_FILIAL = @cFil_SG1 and G1_COD = @cTRB_COD)
				else                 select @G1Niv = isnull(min(G1_NIV), '  ') from SG1### where D_E_L_E_T_ = ' ' and G1_FILIAL = @cFil_SG1 and G1_COD = @cTRB_COD

				if @G1Niv <> '  ' begin
					select @cTRB_NIVEL = convert(char(2),100 - convert(integer,@G1Niv))
					if @IN_MV_PROCQE6 = '1' and @D7OrigLan <> ' ' and @cNPrCQE6 = ' ' begin
						if @cTRB_CF in ('DE6','RE6','DE7','RE7')   select @cTRB_NIVEL = (@cTRB_NIVEL||'w')
						else                                       select @cTRB_NIVEL = (@cTRB_NIVEL||' ')
					end else begin
						if @cTRB_CF in ('DE4','RE4','DE7','RE7')   select @cTRB_NIVEL = (@cTRB_NIVEL||'w')
						else                                       select @cTRB_NIVEL = (@cTRB_NIVEL||' ')
					end
				end else begin
					select @cAux = isnull(@cAux,' ')
					if @cAux = ' ' and @D7OrigLan = ' '  select @cTRB_NIVEL = "  w"
					else                                 select @cTRB_NIVEL = @cAux
				end

				if substring(@cTRB_CF,2,2) = 'E6' begin
					select @cNumSeq = isnull(max(D3_NUMSEQ),' ')
					from SD3###
					where D_E_L_E_T_ = ' ' and D3_ESTORNO <> 'S' and D3_FILIAL = @cFil_SD3 and D3_NUMSEQ = @cTRB_SEQ and
						D3_LOCAL = @IN_MV_CQ and D3_COD = @cTRB_COD and D3_QUANT = @nTRB_QUANT

					if @cNumSeq = ' ' begin
						if @IN_MV_PAR18 = 1     select @cTRB_NIVSD3 = '1'
						else                    select @cTRB_NIVSD3 = '9'
					end
				end
				select @cTRB_TIPO = "T"
			end
			/*fim do trecho corresponde a função A330Estru*/
			select @cBKP_NIVSD3 = @cTRB_NIVSD3
			end else if (substring(@cTRB_CF,2,2) <> 'E3' and @cOrdem <> '280') begin
			select @cTRB_NIVSD3 = '9'
			end else if (@cOrdem <> '280') begin
			select @cTRB_NIVSD3 = '7'
			end

			if @cTRB_CF in ('DE4','DE7','DE6') begin
            select @cOldTRB_NIVEL  = @cTRB_NIVEL
            select @cOldTRB_NIVSD3 = @cTRB_NIVSD3
            select @cOldTRB_TIPO = @cTRB_TIPO
			select @cOldTRB_CF = @cTRB_CF

            /*Busca cf, nivel, nivsd e tipo do movimento de origem (RE)*/
            select
               @cTRB_NIVEL = TRB.TRB_NIVEL,
               @cTRB_NIVSD3 = TRB.TRB_NIVSD3,
               @cTRB_TIPO = TRB.TRB_TIPO,
               @cTRB_CFAUX = TRB.TRB_CF
            from TRB### TRB
            where TRB.TRB_FILIAL = @cFILIALCOR and TRB.TRB_ALIAS = 'SD3' and
               TRB.TRB_SEQ = @cTRB_SEQ and TRB.TRB_DTORIG = @dTRB_DTORIG and
               TRB.TRB_CF <> 'RE5' and
               substring(TRB.TRB_CF,1,1) = 'R' and
               (substring(@cTRB_CF,1,1) || substring(@cTRB_CFAUX,2,2) = 'DE7' or TRB.TRB_QUANT = @nTRX_QUANT ) and TRB.D_E_L_E_T_ = ' '
               group by TRB.TRB_NIVEL, TRB.TRB_NIVSD3, TRB.TRB_TIPO, TRB.TRB_CF
			if (@cTRB_CFAUX is null ) or  @cTRB_CFAUX = '   ' begin select @cTRB_CF = @cOldTRB_CF
			end else begin
				select @cTRB_CF = substring(@cTRB_CF,1,1) || substring(@cTRB_CFAUX,2,2)
			end

            if (@cTRB_NIVEL is null ) select @cTRB_NIVEL = @cOldTRB_NIVEL
            if (@cTRB_NIVSD3 is null ) select @cTRB_NIVSD3 = @cOldTRB_NIVSD3
            if (@cTRB_TIPO is null ) select @cTRB_TIPO = @cOldTRB_TIPO

            /*Corrige CF no caso de troca (MV_PROCQE6)*/
            update SD3### set D3_CF = @cTRB_CF where R_E_C_N_O_ = @nRECFILE

            select @cBKP_NIVSD3 = @cTRB_NIVSD3
			end

			if substring(@cTRB_CF,2,2) = 'E6' begin
            if @cTRB_LOCAL <> @IN_MV_CQ begin
               if @IN_MV_PAR18 = 1	select @cTRB_NIVSD3 = '1'
               else				      select @cTRB_NIVSD3 = '9'

               /* Verifica se é entrada de liberacao de CQ, neste caso, volta cNivSD3*/
               select @nAux = count(D3_NUMSEQ)
               from SD3###
               where D_E_L_E_T_ = ' ' and D3_FILIAL = @cFil_SD3 and
                  D3_NUMSEQ = @cTRB_SEQ and D3_LOCAL = @IN_MV_CQ and D3_ESTORNO <> 'S'

               if @nAux > 0 begin
                  select @cTRB_NIVSD3 = @cBKP_NIVSD3
               end
            end
			end

			/* Reordena entradas de CQ conforme movimento origem: inicio do trecho corresponde a função A330NivCQ */
			if @cTRB_CF in ('RE6','DE6') and @IN_MV_PAR14 <> 1 begin
            if @nTRB_QUANT > 0 begin
               select @D7OrigLan = isnull(D7_ORIGLAN,'  '), @cNumSeq = D7_NUMSEQ
               from SD7###
               where D_E_L_E_T_ = ' ' and D7_FILIAL = @cFil_SD7 and D7_NUMERO = substring(@cTRB_DOC,1,len(D7_NUMERO)) and
                  D7_PRODUTO = @cTRB_COD and D7_LOCAL = @IN_MV_CQ and D7_TIPO = 0

               if @D7OrigLan = 'CP' begin
                  select @cOldORDEM = @cOrdem
                  select @cOldTRB_NIVEL  = @cTRB_NIVEL
                  select @cOldTRB_NIVSD3 = @cTRB_NIVSD3
                  select @cTRB_CHAVEREAD = ' '

                  select @cTRB_CHAVEREAD = TRB_CHAVE, @cOrdem = TRB_ORDEM, @cTRB_NIVEL = TRB_NIVEL, @cTRB_NIVSD3 = TRB_NIVSD3,
                     @nTRB_RECSD1 = TRB_RECNO
                  from TRB###
                  where TRB_FILIAL = @cFILIALCOR and TRB_ALIAS = 'SD1' and TRB_SEQ = @cNumSeq and D_E_L_E_T_ = ' '

                  if ( @cTRB_CHAVEREAD <> ' ')
                  begin
                     select @cOldTRB_CHAVE = @cTRB_CHAVE
                     select @cTRB_CHAVE = ' '

                     select @cTRB_SEQ = D1_NUMSEQ,
                           @cTRB_DOC = D1_DOC,       @cTRB_SERIE  = D1_SERIE,
                           @cD1_FORNECE = D1_FORNECE
                     from SD1### (nolock)
                     where R_E_C_N_O_ = @nTRB_RECSD1

                     if @cOrdem = '500' and @IN_SEQ500 = '1' begin
                        If rtrim(@cTRB_CHAVEREAD) = (@cTRB_SEQ||@cD1_FORNECE||@dTRB_DTORIG||@cTRB_DOC||@cTRB_SERIE)
                        begin
                           select @cTRB_CHAVE = (@cTRB_SEQ||@cD1_FORNECE||@dTRB_DTORIG||@cTRB_DOC||@cTRB_SERIE||'x')
                        end
                     end

                     If @cTRB_CHAVE = ' ' and rtrim(@cTRB_CHAVEREAD) = (@cD1_FORNECE||@dTRB_DTORIG||@cTRB_SEQ||@cTRB_DOC||@cTRB_SERIE)
                     begin
                        select @cTRB_CHAVE = (@cD1_FORNECE||@dTRB_DTORIG||@cTRB_SEQ||@cTRB_DOC||@cTRB_SERIE||'x')
                     end

                     If @cTRB_CHAVE = ' '
                     begin
                        select @cTRB_CHAVE = rtrim(@cTRB_CHAVEREAD)||'x'
                     end
                  end
                  if (@cOrdem is null ) select @cOrdem = @cOldORDEM
                  if (@cTRB_NIVEL is null ) select @cTRB_NIVEL = @cOldTRB_NIVEL
                  if (@cTRB_NIVSD3 is null ) select @cTRB_NIVSD3 = @cOldTRB_NIVSD3

               end else if @D7OrigLan = 'PR'	begin

                  select @cOldORDEM = @cOrdem
                  select @cOldTRB_NIVEL  = @cTRB_NIVEL
                  select @cOldTRB_NIVSD3 = @cTRB_NIVSD3
                  select @cTRB_CHAVEREAD = ' '

                  select @cTRB_CHAVEREAD = TRB_CHAVE, @cOrdem = TRB_ORDEM, @cTRB_NIVEL = TRB_NIVEL, @cTRB_NIVSD3 = TRB_NIVSD3
                  from TRB###
                  where TRB_FILIAL = @cFILIALCOR and TRB_COD = @cTRB_COD and TRB_ALIAS = 'SD3' and TRB_SEQ = @cNumSeq and substring(TRB_CF,1,2) = 'PR' and D_E_L_E_T_ = ' '

                  if (@cTRB_CHAVEREAD <> ' ') select @cTRB_CHAVE = rtrim(@cTRB_CHAVEREAD)||'x'
                  if (@cOrdem is null ) select @cOrdem = @cOldORDEM
                  if (@cTRB_NIVEL is null ) select @cTRB_NIVEL = @cOldTRB_NIVEL
                  if (@cTRB_NIVSD3 is null ) select @cTRB_NIVSD3 = @cOldTRB_NIVSD3
               end

            end else begin
               select @cNumSeq = isnull(Max(D7_NUMSEQ),' ')
               from SD7###
               where D_E_L_E_T_ = ' ' and D7_FILIAL = @cFil_SD7 and D7_NUMERO = substring(@cTRB_DOC,1,len(D7_NUMERO)) and
                  D7_PRODUTO = @cTRB_COD and D7_LOCAL = @IN_MV_CQ and D7_TIPO = 8

               if @cNumSeq <> ' ' begin
                  select @cTRB_CHAVEREAD = ' '
                  select @cTRB_CHAVEREAD = TRB_CHAVE, @cOrdem = TRB_ORDEM, @cTRB_NIVEL = TRB_NIVEL,  @cTRB_NIVSD3 = TRB_NIVSD3
                  from TRB###
                  where TRB_FILIAL = @cFILIALCOR and TRB_ALIAS = 'SD1' and TRB_SEQ = @cNumSeq and D_E_L_E_T_ = ' '
                  if (@cTRB_CHAVEREAD <> ' ') select @cTRB_CHAVE = rtrim(@cTRB_CHAVEREAD)||'x'
               end
            end

            if @cOrdem = '100' and @IN_MV_330JCM1 like '%1%' select @cOrdem = '101'

         end /*fim do trecho corresponde a função A330NivCQ */
	   end
      if @cTRB_NIVEL = '  ' begin
         if @IN_MV_PAR11  = 1 begin
            select @G1Niv = Isnull(min(G1_NIV),'  ')
            from TRB###SG1
            where G1_FILIAL  = @cFil_SG1  and G1_COD  = @cTRB_COD  and G1_FILPROC  = @cFILIALPROC and D_E_L_E_T_  = ' '
         end else begin
            select @G1Niv = Isnull(min(G1_NIV),'  ')
            from SG1###
            where G1_FILIAL  = @cFil_SG1  and G1_COD  = @cTRB_COD and D_E_L_E_T_  = ' '
         end
         if @G1Niv <> '  ' begin
            select @cTRB_NIVEL = convert(char(2),100 - convert(integer,@G1Niv))
         end
      end

      if @cAlias = 'SD3' begin
         if ( substring( @cTRB_COD, 1, 3 ) = 'MOD' )  begin
            select @cTRB_MOD = '1'
         end else begin
            if @IN_MV_PRODMOD = '1' AND @cB1_CCCUSTO <> ' ' begin
               select @cTRB_MOD = '1'
            end else begin
               select @cTRB_MOD = '0'
            end
         end
      end else begin
         exec MAT059_## @cFILIALCOR,@cTRB_COD,@IN_MV_PRODMOD,@cTRB_MOD output
      end

      if (@lGrava = '1') begin
         /* ------------------------------------------------------------------------------------------------------------
            Inserindo registro no arquivo de trabalho
         ------------------------------------------------------------------------------------------------------------ */
         begin transaction
            select @dTRB_DTBASE = @dTRB_DTORIG
			   select @cTRB_CHAVE = Isnull(@cTRB_CHAVE,'  ')
            if (@IN_MV_PAR14 <> 3) select @dTRB_DTBASE = @IN_MV_PAR1
            -- campo que indica se usa transferencia
            if (@cRetFil <> ' ' )  select @cTRB_FILTRA = 'S'

            insert into TRB### ( TRB_FILIAL,   TRB_FILTRA,   TRB_ALIAS,    TRB_RECNO,    TRB_ORDEM,   TRB_CHAVE,    TRB_NIVEL,
                                 TRB_NIVSD3,   TRB_COD,      TRB_DTBASE,   TRB_OP,       TRB_CF,      TRB_SEQ,      TRB_SEQPRO,
                                 TRB_DTORIG,   TRB_RECSD1,   TRB_TES,      TRB_DOC,      TRB_SERIE,   TRB_TIPO,     TRB_LOCAL,
                                 TRB_RECTRB,   TRB_TIPONF,   TRB_QUANT,    TRB_USATRA,   TRB_ITEM,    TRB_MOD)
               values          ( @cFILIALCOR,  @cRetFil,     @cAlias,      @nRECFILE,    @cOrdem,     @cTRB_CHAVE,  @cTRB_NIVEL,
                                 @cTRB_NIVSD3, @cTRB_COD,    @dTRB_DTBASE, @cTRB_OP,     @cTRB_CF,    @cTRB_SEQ,    @cTRB_SEQPRO,
                                 @dTRB_DTORIG, @cNRECRE5,    @cTRB_TES,    @cTRB_DOC,    @cTRB_SERIE, @cTRB_TIPO,   @cTRB_LOCAL,
                                 @nNRECTRB,    @cTRB_TIPONF, @nTRB_QUANT,  @cTRB_FILTRA, @cTRB_ITEM,  @cTRB_MOD )
         commit transaction
      end
   end
end
