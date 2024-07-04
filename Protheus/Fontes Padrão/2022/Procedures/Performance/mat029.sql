Create procedure MAT029_##
(
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_PROD         char('B1_COD'),
 @IN_LOCAL        char('B1_LOCPAD'),
 @IN_DATA         char(08),
 @IN_LOTE         char('BJ_LOTECTL'),
 @IN_SUBLOTE      char('BK_NUMLOTE'),
 @IN_LOCALIZA     char('BK_LOCALIZ'),
 @IN_NUMSER       char('BK_NUMSERI'),
 @IN_CONSSUB      char(01),
 @IN_MV_ULMES     char(08),
 @IN_300SALNEG    char(01),
 @IN_MV_WMSNEW    char(01),
 @IN_PRDORI       char('B1_COD'),
 @OUT_SALDO1      float OutPut,
 @OUT_SALDO2      float OutPut,
 @OUT_SALDO3      float OutPut,
 @OUT_SALDO4      float OutPut,
 @OUT_SALDO5      float OutPut,
 @OUT_SALDO6      float OutPut,
 @OUT_SALDO7      float OutPut
)
as


/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> CalcEstL (Função do SIGA) </s>
    Descricao   -  <d> Retorna o Saldo inicial por do Produto/Local do arquivo SD5 </d>
    Assinatura  -  <a> 003 </a>
    Entrada     -  <ri> @IN_FILIALCOR - Filial corrente
                   @IN_PROD      - Codigo do Produto
                   @IN_LOCAL     - Local (Almoxerifado)
                   @IN_DATA      - Data para obter saldo inicial
                   @IN_LOTE      - Lote
                   @IN_SUBLOTE   - Sublote
                   @IN_LOCALIZA  - Localização
                   @IN_NUMSER    - Número de Série
                   @IN_CONSSUB   - Verifica se obtem saldo por Sub-lote com rastro </ri>

    Saida       -  <ro> @OUT_SALDO1   - Saldos de saida
                   @OUT_SALDO2   -       " "
                   @OUT_SALDO3   -       " "
                   @OUT_SALDO4   -       " "
                   @OUT_SALDO5   -       " "
                   @OUT_SALDO6   -       " "
                   @OUT_SALDO7   -       " " </ro>

    Responsavel :  <r> Ricardo Gonçalves </r>
    Data        :  <dt> 23.07.2001 </dt>
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFilial_SBJ       Char('BJ_FILIAL')
Declare @cFilial_SBK       Char('BK_FILIAL')
Declare @cFilial_SD5       Char('D5_FILIAL')
Declare @cFilial_SDB       Char('DB_FILIAL')


/* -------------------------------------------------------------------
   Variaveis da procedure
------------------------------------------------------------------- */
Declare @cRastroL      char(01)
Declare @cRastroS      char(01)
Declare @lAvalia       char(01)
Declare @cDtSaldo      char(08)
Declare @execDB        char(01)

/* -------------------------------------------------------------------
   Variaveis do cursor
------------------------------------------------------------------- */
Declare @nBJ_QINI      decimal( 'BJ_QINI' )
Declare @nBJ_QISEGUM   decimal( 'BJ_QISEGUM' )
Declare @cBJ_NUMLOTE   char('BJ_NUMLOTE')
Declare @cBJ_DATA      char(08)

Declare @nBK_QINI      decimal( 'BK_QINI' )
Declare @nBK_QISEGUM   decimal( 'BK_QISEGUM' )
Declare @cBK_NUMLOTE   char('BK_NUMLOTE')
Declare @cBK_LOTECTL   char('BK_LOTECTL')
Declare @cBK_DATA      char(08)

Declare @cAux          Varchar(3)
Declare @cAux1         Varchar(1)
Declare @nSLD1SD5      float
Declare @nSLD7SD5      float
Declare @nSLD1SDB      float
Declare @nSLD7SDB      float
Declare @cProduto      char('B1_COD')
Declare @cLocal        char('B1_LOCPAD')
Declare @cData         char(08)
Declare @cLote         char('BJ_LOTECTL')
Declare @cSubLote      char('BK_NUMLOTE')
Declare @cLocaliza     char('BK_LOCALIZ')
Declare @cNumSer       char('BK_NUMSERI')

Begin

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   Select @cProduto  = @IN_PROD
   Select @cLocal    = @IN_LOCAL
   Select @cData     = @IN_DATA
   Select @cLote     = @IN_LOTE
   Select @cSubLote  = @IN_SUBLOTE
   Select @cLocaliza = @IN_LOCALIZA
   Select @cNumSer   = @IN_NUMSER

   select @cDtSaldo = null

   /* -----------------------------------------------------------------
      Recupera filiais das tabelas
   ----------------------------------------------------------------- */
   select @cAux = 'SBJ'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_SBJ OutPut
   select @cAux = 'SBK'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_SBK OutPut
   select @cAux = 'SD5'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_SD5 OutPut
   select @cAux = 'SDB'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFilial_SDB OutPut

   /* ----------------------------------------------------------------
      Obtem rastro com lote ou sub-lote do produto
   ---------------------------------------------------------------- */
   select @cAux  = 'S'
   select @cAux1 = null
   exec MAT011_## @cAux , @cProduto, @cAux1, @IN_FILIALCOR, @cRastroL output
   select @cAux = 'S'
   exec MAT011_## @cAux, @cProduto, @cAux,  @IN_FILIALCOR, @cRastroS output

   /* -------------------------------------------------------------------------------------------------------------------
      Zerando variaveis de saida
   ------------------------------------------------------------------------------------------------------------------- */
   select @OUT_SALDO1 = 0
   select @OUT_SALDO2 = 0
   select @OUT_SALDO3 = 0
   select @OUT_SALDO4 = 0
   select @OUT_SALDO5 = 0
   select @OUT_SALDO6 = 0
   select @OUT_SALDO7 = 0
   select @execDB     = '1'
   select @nSLD1SD5   = 0
   select @nSLD7SD5   = 0
   select @nSLD1SDB   = 0
   select @nSLD7SDB   = 0

   /* ----------------------------------------------------------------
   Verifica se obtem saldo por Sub-lote mesmo com rastro
   ---------------------------------------------------------------- */
   if (@IN_CONSSUB = '1') and @cRastroL = '1' and (@cSubLote <> ' ')
      select @cRastroS = '1'

   if (ISNULL(LTRIM(RTRIM(@cLocaliza || @cNumSer)),' ') = ' ') and (@cLote <> ' ') begin
      /* ----------------------------------------------------------------
         Obtem os saldos para ultima data de fechamento
      ---------------------------------------------------------------- */
      declare CUR_MAT029_A insensitive cursor for
         select BJ_QINI, BJ_QISEGUM, BJ_NUMLOTE, BJ_DATA
         from SBJ### (nolock)
         where BJ_FILIAL     = @cFilial_SBJ
            and BJ_COD       = @cProduto
            and BJ_LOCAL     = @cLocal
            and BJ_LOTECTL   = @cLote
            and BJ_NUMLOTE   = @cSubLote
            and BJ_DATA      = (select max(BJ_DATA)
                                from SBJ### (nolock)
                                where BJ_FILIAL   = @cFilial_SBJ
                                   and BJ_COD      = @cProduto
                                   and BJ_LOCAL    = @cLocal
                                   and BJ_LOTECTL  = @cLote
                                   and BJ_DATA     < @cData
                                   and BJ_NUMLOTE  = @cSubLote
                                   and D_E_L_E_T_  = ' ')
            and D_E_L_E_T_   = ' '
      for read only

      open CUR_MAT029_A

      fetch CUR_MAT029_A into @nBJ_QINI, @nBJ_QISEGUM, @cBJ_NUMLOTE, @cBJ_DATA

      while (@@Fetch_status = 0) begin

         select @lAvalia = '1'

         /* ---------------------------------------------------------------------------------
            Filtro por sub-lote
         --------------------------------------------------------------------------------- */
         if (@cSubLote <> ' ') and (@cRastroS = '1') and (@cBJ_NUMLOTE <> @cSubLote )
            select @lAvalia = '0'

         if @lAvalia = '1' begin
            select @OUT_SALDO1 = @nBJ_QINI
            select @OUT_SALDO7 = @nBJ_QISEGUM
            select @cDtSaldo   = @cBJ_DATA
         end

         /* ------------------------------------------------------------------------------------------------------
            Tratamento para o DB2
         ------------------------------------------------------------------------------------------------------ */
         SELECT @fim_CUR = 0

         fetch CUR_MAT029_A into @nBJ_QINI, @nBJ_QISEGUM, @cBJ_NUMLOTE, @cBJ_DATA
      end

      close CUR_MAT029_A
      deallocate CUR_MAT029_A

      if @OUT_SALDO1 is null select @OUT_SALDO1 = 0
      if @OUT_SALDO7 is null select @OUT_SALDO7 = 0

      /* ----------------------------------------------------------------
         Procurando movimentações no SD5
      ---------------------------------------------------------------- */
      if ( @IN_300SALNEG = '1' or  (@OUT_SALDO1 + @OUT_SALDO7 = 0) )  or  ( @IN_300SALNEG = '1' or   ((@OUT_SALDO1 + @OUT_SALDO7 > 0) )  and (@cDtSaldo is not null)) begin
         if @cDtSaldo is null Select @cDtSaldo = '19800101'

         /* ----------------------------------------------------------------------------------------------------------
            Executa o cursor CUR_MAT029_B na procedure MAT045, para tratar a variavel cDtSaldo dinamicamente no cursor
         ---------------------------------------------------------------------------------------------------------- */
         select @nSLD1SD5 = @OUT_SALDO1
         select @nSLD7SD5 = @OUT_SALDO7
         if @nSLD1SD5 is null select @nSLD1SD5 = 0
         if @nSLD7SD5 is null select @nSLD7SD5 = 0

         exec MAT045_## @cFilial_SD5 , @cProduto , @cLocal , @cLote , @cData , @cSubLote , @cDtSaldo , @cRastroS , @nSLD1SD5 , @nSLD7SD5 , @OUT_SALDO1 OutPut , @OUT_SALDO7 OutPut
      end

   end else if (ISNULL(LTRIM(RTRIM(@cLocaliza || @cNumSer)),' ') <> ' ') begin
      /* ----------------------------------------------------------------
         Obtem os saldos para ultima data de fechamento
      ---------------------------------------------------------------- */
      declare CUR_MAT029_C insensitive cursor for
         select BK_QINI,
                  BK_QISEGUM,
                  BK_NUMLOTE,
                  BK_LOTECTL,
                  BK_DATA
            from SBK### (nolock)
            where BK_FILIAL   = @cFilial_SBK
            and BK_COD        = @cProduto
            and BK_LOCAL      = @cLocal
            and BK_LOCALIZ    = @cLocaliza
            and BK_NUMSERI    = @cNumSer
            and BK_LOTECTL    = @cLote
            and BK_DATA       = (select max(BK_DATA)
                                    from SBK### (nolock)
                                    where BK_FILIAL = @cFilial_SBK
                                    and BK_COD      = @cProduto
                                    and BK_LOCAL    = @cLocal
                                    and BK_LOTECTL  = @cLote
                                    and BK_LOCALIZ  = @cLocaliza
                                    and BK_NUMSERI  = @cNumSer
                                    and BK_DATA		< @cData
                                    and D_E_L_E_T_  = ' ')
            and D_E_L_E_T_    = ' '
      for read only

      open CUR_MAT029_C

      fetch CUR_MAT029_C into @nBK_QINI, @nBK_QISEGUM, @cBK_NUMLOTE, @cBK_LOTECTL, @cBK_DATA

      while (@@Fetch_status = 0) begin

         select @lAvalia = '1'

         /* -------------------------------------------------------------------------------------------------
            Verifica se existe rastro e aplica filtros por lote e sub-lote
         ------------------------------------------------------------------------------------------------- */
         if @cRastroL = '1' begin
            if @cLote <> @cBK_LOTECTL
               select @lAvalia = '0'

            if @lAvalia = '1' and (@cSubLote <> ' ') and (@cRastroS = '1') and (@cBK_NUMLOTE <> @cSubLote)
               select @lAvalia = '0'
         end

         if @lAvalia = '1' begin
            select @OUT_SALDO1 = @nBK_QINI
            select @OUT_SALDO7 = @nBK_QISEGUM
            select @cDtSaldo   = @cBK_DATA
            if @cBK_DATA = @cData
               select @execDB     = '0'
         end

         fetch CUR_MAT029_C into @nBK_QINI, @nBK_QISEGUM, @cBK_NUMLOTE, @cBK_LOTECTL, @cBK_DATA
      end

      close CUR_MAT029_C

      /* ------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      ------------------------------------------------------------------------------------------------------ */
      SELECT @fim_CUR = 0

      deallocate CUR_MAT029_C

      if @OUT_SALDO1 is null select @OUT_SALDO1 = 0
      if @OUT_SALDO7 is null select @OUT_SALDO7 = 0

      /* ----------------------------------------------------------------
         Procurando movimentações no SDB
      ---------------------------------------------------------------- */
      if @execDB = '1' and (@IN_300SALNEG = '1' or (@OUT_SALDO1 + @OUT_SALDO7 = 0) or ( @IN_300SALNEG = '1' or (@OUT_SALDO1 + @OUT_SALDO7 > 0) and (@cDtSaldo is not null))) begin
         if @cDtSaldo is null Select @cDtSaldo = '19800101'

         /* ----------------------------------------------------------------------------------------------------------
            Executa o cursor CUR_MAT029_D na procedure MAT046, para tratar a variavel cDtSaldo dinamicamente no cursor
         ---------------------------------------------------------------------------------------------------------- */
         select @nSLD1SDB = @OUT_SALDO1
         select @nSLD7SDB = @OUT_SALDO7
         if @nSLD1SDB is null select @nSLD1SDB = 0
         if @nSLD7SDB is null select @nSLD7SDB = 0

         EXEC MAT046_## @cFilial_SDB , @cProduto , @cLocal , @cLote , @cLocaliza , @cNumSer , @cSubLote , @cData , @cDtSaldo , @cRastroL , @cRastroS , @nSLD1SDB , @nSLD7SDB ,@IN_MV_WMSNEW, @IN_PRDORI, @OUT_SALDO1 OutPut, @OUT_SALDO7 OutPut

         if @OUT_SALDO1 is null select @OUT_SALDO1 = 0
         if @OUT_SALDO7 is null select @OUT_SALDO7 = 0
      end
   end
End