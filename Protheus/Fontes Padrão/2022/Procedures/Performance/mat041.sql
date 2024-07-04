create procedure MAT041_##
(
 @IN_FILIALCOR  char('B1_FILIAL'),
 @IN_MV_PAR01   char('B1_COD'),
 @IN_MV_PAR02   char('B1_COD'),
 @OUT_RESULTADO char(01) output
)
as

/* ---------------------------------------------------------------------------------------------------------------------
	 Versão      :   <v> Protheus P12 </v>
	 -----------------------------------------------------------------------------------------------------------------
	 Programa	 :   <s> MATA216	</s>
	 -----------------------------------------------------------------------------------------------------------------
	 Assinatura	 :   <a> 001 </a>
	 -----------------------------------------------------------------------------------------------------------------
	 Descricao	 :   <d> Refaz o arquivo de Saldos de/em Poder de Terceiros </d>
	 -----------------------------------------------------------------------------------------------------------------
	 Entrada 	 :  <ri> @IN_FILIALCOR	- Filial corrente </ri>
	 -----------------------------------------------------------------------------------------------------------------
	 Saida		 :  <ro> @OUT_RESULTADO - Retorno de processamento </ro>
	 -----------------------------------------------------------------------------------------------------------------
	 Versão		 :   <v> Advanced Protheus </v>
	 -----------------------------------------------------------------------------------------------------------------
	 Observações :   <o>   </o>
	 -----------------------------------------------------------------------------------------------------------------
	 Responsavel :   <r> Ricardo Gonçalves </r>
	 -----------------------------------------------------------------------------------------------------------------
	 Data 		 :  <dt> 21/03/2002 </dt>

         Estrutura de chamadas
         ========= == ========

         0.MAT041 - Refaz o arquivo de Saldos de/em Poder de Terceiros
           1.MAT035 - Calcula saldo em poder de terceiros
           1.MAT025 - Padrao para criar registros no arquivo de saldos em estoque (SB2)

	 -----------------------------------------------------------------------------------------------------------------
	 Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SB2   char('B2_FILIAL')
Declare @cFil_SB6   char('B6_FILIAL')
Declare @cFil_SC6   char('C6_FILIAL')
Declare @cFil_SC9   char('C9_FILIAL')
Declare @cFil_SD1   char('D1_FILIAL')
Declare @cFil_SD2   char('D2_FILIAL')
Declare @cFil_SF4   char('F4_FILIAL')

Declare @cD2_CLIENTE    char( 'D2_CLIENTE' )
declare @cD2_LOJA       char( 'D2_LOJA' )
declare @cD2_COD        char( 'D2_COD' )
declare @cD2_LOCAL      char( 'D2_LOCAL' )
declare @cD2_SEGUM      char( 'D2_SEGUM' )
declare @cD2_DOC        char( 'D2_DOC' )
declare @cD2_SERIE      char( 'D2_SERIE' )
declare @dD2_EMISSAO    char( 'D2_EMISSAO' )
declare @cD2_TIPO       char( 'D2_TIPO' )
Declare @cD2_NFORI      Char( 'D2_NFORI' )
Declare @cD2_SERIORI    Char( 'D2_SERIORI' )
Declare @cD2_ITEMORI    Char( 'D2_ITEMORI' )
Declare @cD2_TES        Char( 'D2_TES' )
Declare @cD2_UM         Char( 'D2_UM' )
Declare @cD2_IDENTB6    Char( 'D2_IDENTB6' )
Declare @cD2_NUMSEQ     Char( 'D2_NUMSEQ' )

Declare @cD1_FORNECE    char( 'D1_FORNECE' )
declare @cD1_LOJA       char( 'D1_LOJA' )
declare @cD1_COD        char( 'D1_COD' )
declare @cD1_LOCAL      char( 'D1_LOCAL' )
declare @cD1_SEGUM      char( 'D1_SEGUM' )
declare @cD1_DOC        char( 'D1_DOC' )
declare @cD1_SERIE      char( 'D1_SERIE' )
declare @dD1_EMISSAO    char( 'D1_EMISSAO' )
declare @cD1_TES        char( 'D1_TES' )
declare @cD1_UM	      char( 'D1_UM' )
declare @cD1_IDENTB6    char( 'D1_IDENTB6' )
declare @cD1_NUMSEQ     char( 'D1_NUMSEQ' )
declare @cD1_TIPO       char( 'D1_TIPO' )
Declare @cD1_NFORI      Char( 'D1_NFORI' )
Declare @cD1_SERIORI    Char( 'D1_SERIORI' )
Declare @cD1_ITEMORI    Char( 'D1_ITEMORI' )
Declare @dD1_DTDIGIT    Char( 'D1_DTDIGIT' )

declare @cB6_PODER3     char( 'B6_PODER3' )
declare @dB6_UENT       char( 'B6_UENT' )
declare @cB6_IDENT	   char( 'B6_IDENT' )
declare @cB6_LOCAL	   char( 'B6_LOCAL' )
declare @cB6_PRODUTO	   char( 'B6_PRODUTO' )
declare @cB6_TES	      char( 'B6_TES' )
declare @cB6_ATEND	   char( 'B6_ATEND' )
declare @cB6_ESTOQUE    char( 'B6_ESTOQUE' )
Declare @cB6_TIPO       char( 'B6_TIPO' )
Declare @cB6_TPCF       char( 'B6_TPCF' )
Declare @cXB6_IDENTB6   Char( 'B6_IDENTB6' )
Declare @cB6_IDENTB6    Char( 'B6_IDENTB6' )
Declare @cXB6_PODER3    Char( 'B6_PODER3' )
Declare @cXB6_UENT      Char( 'B6_UENT' )
Declare @cB6_ORIGLAN    Char( 'B6_ORIGLAN' )
Declare @cXB6_TPCF      Char( 'B6_TPCF' )
Declare @cXB6_TIPO      Char( 'B6_TIPO' )
Declare @cXB6_IDENT     Char( 'B6_IDENT' )
Declare @cIdentSB6      Char( 'B6_IDENT' )
Declare @cB6_DOC        Char( 'B6_DOC' )
Declare @cB6_SERIE      Char( 'B6_SERIE' )
Declare @cB6_CLIPROP    Char( 'B6_CLIFOR')
Declare @cB6_LJCLIPR    Char( 'B6_LOJA')

declare @cF4_PODER3     char( 'F4_PODER3' )
declare @cF4_ESTOQUE	   char( 'F4_ESTOQUE' )

Declare @cC9_NFISCAL    Char( 'C9_NFISCAL' )

Declare @lProcessa      char( 01 )

declare @nD2_QUANT      decimal( 'D2_QUANT' )
declare @nD2_PRCVEN     decimal( 'D2_PRCVEN' )
declare @nD2_CUSTO1     decimal( 'D2_CUSTO1' )
declare @nD2_CUSTO2     decimal( 'D2_CUSTO2' )
declare @nD2_CUSTO3     decimal( 'D2_CUSTO3' )
declare @nD2_CUSTO4     decimal( 'D2_CUSTO4' )
declare @nD2_CUSTO5     decimal( 'D2_CUSTO5' )
declare @nD2_QTSEGUM    decimal( 'D2_QTSEGUM' )
declare @nD2_CUSFF1     decimal( 'D2_CUSFF1' )
declare @nD2_CUSFF2     decimal( 'D2_CUSFF2' )
declare @nD2_CUSFF3     decimal( 'D2_CUSFF3' )
declare @nD2_CUSFF4     decimal( 'D2_CUSFF4' )
declare @nD2_CUSFF5     decimal( 'D2_CUSFF5' )

declare @nD1_QUANT	   decimal( 'D1_QUANT' )
declare @nD1_VUNIT	   decimal( 'D1_VUNIT' )
declare @nD1_QTSEGUM 	decimal( 'D1_QTSEGUM' )
declare @nD1_CUSTO	   decimal( 'D1_CUSTO' )
declare @nD1_CUSTO2	   decimal( 'D1_CUSTO2' )
declare @nD1_CUSTO3	   decimal( 'D1_CUSTO3' )
declare @nD1_CUSTO4	   decimal( 'D1_CUSTO4' )
declare @nD1_CUSTO5  	decimal( 'D1_CUSTO5' )

declare @nD1_CUSFF1     decimal( 'D1_CUSFF1' )
declare @nD1_CUSFF2     decimal( 'D1_CUSFF2' )
declare @nD1_CUSFF3     decimal( 'D1_CUSFF3' )
declare @nD1_CUSFF4     decimal( 'D1_CUSFF4' )
declare @nD1_CUSFF5     decimal( 'D1_CUSFF5' )

Declare @nB2_QTNP     Decimal( 'B2_QTNP' )
Declare @nXB2_QTNP    Decimal( 'B2_QTNP' )
Declare @nB2_QNPT     Decimal( 'B2_QNPT' )
Declare @nXB2_QNPT    Decimal( 'B2_QNPT' )
Declare @nB2_QTER     Decimal( 'B2_QTER' )
Declare @nXB2_QTER    Decimal( 'B2_QTER' )
Declare @nB6_QUANTAux Decimal( 'B6_QUANT' )

declare @nB6_SALDO    decimal( 'B6_SALDO' )
declare @nB6_PRUNIT   decimal( 'B6_PRUNIT' )
declare @nB6_QULIB    decimal( 'B6_QULIB' )
declare @nB6_QUANT    decimal( 'B6_QUANT' )
Declare @nXB6_SALDO   Decimal( 'B6_SALDO' )
Declare @nXXB6_SALDO  Decimal( 'B6_SALDO' )
declare @cXB6_ESTOQUE Char( 'B6_ESTOQUE' )

declare @nXB6_QUANT   decimal( 'B6_QUANT' )

declare @nXB6_CUSTO1  decimal( 'B6_CUSTO1' )
declare @nXB6_CUSTO2  decimal( 'B6_CUSTO2' )
declare @nXB6_CUSTO3  decimal( 'B6_CUSTO3' )
declare @nXB6_CUSTO4  decimal( 'B6_CUSTO4' )
declare @nXB6_CUSTO5  decimal( 'B6_CUSTO5' )

declare @nXB6_CUSFF1  decimal( 'B6_CUSFF1' )
declare @nXB6_CUSFF2  decimal( 'B6_CUSFF2' )
declare @nXB6_CUSFF3  decimal( 'B6_CUSFF3' )
declare @nXB6_CUSFF4  decimal( 'B6_CUSFF4' )
declare @nXB6_CUSFF5  decimal( 'B6_CUSFF5' )

declare @nXB6_CCOMP1  decimal( 'B6_CUSTO1' )
declare @nXB6_CCOMP2  decimal( 'B6_CUSTO2' )
declare @nXB6_CCOMP3  decimal( 'B6_CUSTO3' )
declare @nXB6_CCOMP4  decimal( 'B6_CUSTO4' )
declare @nXB6_CCOMP5  decimal( 'B6_CUSTO5' )

declare @nXB6_CFFCOM1  decimal( 'B6_CUSFF1' )
declare @nXB6_CFFCOM2  decimal( 'B6_CUSFF2' )
declare @nXB6_CFFCOM3  decimal( 'B6_CUSFF3' )
declare @nXB6_CFFCOM4  decimal( 'B6_CUSFF4' )
declare @nXB6_CFFCOM5  decimal( 'B6_CUSFF5' )

declare @nC9_QTDLIB  decimal( 'C9_QTDLIB' )
declare @nB6_TQULIB  decimal( 'C9_QTDLIB' )

declare @iSD2_RECNO  integer
declare @iSD1_RECNO  integer
declare @iRecnoSF4   integer
declare @iB6_RECNO   integer
declare @iSB6_RECNO  integer
Declare @iRecno	   integer
Declare @iRecCount   Integer
Declare @iRecnoSB6   Integer
Declare @iSC9_RECNO  Integer
Declare @iRecnoSB2   Integer
Declare @iRecnoAux   Integer
Declare @cAux        Varchar(3)
Declare @nContador   Integer
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.
                             -- Será trocada por Commit no CFGX051 após passar pelo Parse
Declare @nAtend      Integer
Declare @nB6_C1TOT   decimal( 'B6_CUSTO1' )
Declare @nB6_C2TOT   decimal( 'B6_CUSTO2' )
Declare @nB6_C3TOT   decimal( 'B6_CUSTO3' )
Declare @nB6_C4TOT   decimal( 'B6_CUSTO4' )
Declare @nB6_C5TOT   decimal( 'B6_CUSTO5' )
Declare @nB6_CFF1TOT decimal( 'B6_CUSFF1' )
Declare @nB6_CFF2TOT decimal( 'B6_CUSFF2' )
Declare @nB6_CFF3TOT decimal( 'B6_CUSFF3' )
Declare @nB6_CFF4TOT decimal( 'B6_CUSFF4' )
Declare @nB6_CFF5TOT decimal( 'B6_CUSFF5' )

begin
   select @OUT_RESULTADO = '0'
   /* ------------------------------------------------------------------------------------------------------------------
      Recupera filiais
      ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SB2'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut
   select @cAux = 'SB6'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB6 OutPut
   select @cAux = 'SC6'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SC6 OutPut
   select @cAux = 'SC9'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SC9 OutPut
   select @cAux = 'SD1'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD1 OutPut
   select @cAux = 'SD2'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD2 OutPut
   select @cAux = 'SF4'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF4 OutPut
   /* ----------------------------------------------------------------------------------------------------------
      Atualizando arquivos de saldos atuais - 1
      ---------------------------------------------------------------------------------------------------------- */
   Begin Tran
      update SB2###
         set B2_QTNP = 0, B2_QNPT = 0, B2_QTER = 0
       where B2_FILIAL	 = @cFil_SB2
         and B2_COD between @IN_MV_PAR01 and @IN_MV_PAR02
         and D_E_L_E_T_  = ' '
   Commit Tran

   /* -------------------------------------------------------------------------------------------------------------------
      Atualizando quantidades SB6 -2
      ------------------------------------------------------------------------------------------------------------------- */
   select @nContador = 0
   declare CUR_B6QTD insensitive cursor for
     select B6_ORIGLAN, B6_PODER3, R_E_C_N_O_
       from SB6###
      Where B6_FILIAL = @cFil_SB6
        and B6_PRODUTO between @IN_MV_PAR01 and @IN_MV_PAR02
        and D_E_L_E_T_  = ' '
   for read only

   open CUR_B6QTD

   Fetch CUR_B6QTD into @cB6_ORIGLAN, @cB6_PODER3, @iRecno

   While @@Fetch_Status = 0 begin

      select @nContador = @nContador + 1
      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End

      delete
        from SB6###
       where R_E_C_N_O_ = @iRecno


      Fetch CUR_B6QTD into @cB6_ORIGLAN, @cB6_PODER3, @iRecno
      If @nContador > 1 begin
         Commit Tran
         select @nContador = 0
      End
   end
   close CUR_B6QTD
   deallocate CUR_B6QTD

   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End

   /* ------------------------------------------------------------------------------------------------------------------
      Verifica no arquivo de notas fiscais de saida se existe algum item
      referente a poder de terceiros - remessa  - 3
      ------------------------------------------------------------------------------------------------------------------ */
   select @nContador = 0
   declare CUR_SD2 insensitive cursor for
   select D2_CLIENTE, D2_LOJA,	 D2_COD,     D2_LOCAL,  D2_SEGUM,  D2_DOC,    D2_SERIE,
          D2_EMISSAO, D2_QUANT,  D2_PRCVEN,  D2_TES,    F4_PODER3, D2_UM,     D2_QTSEGUM,
          D2_IDENTB6, D2_NUMSEQ, D2_CUSTO1,  D2_CUSTO2, D2_CUSTO3, D2_CUSTO4, D2_CUSTO5,
          D2_CUSFF1,  D2_CUSFF2, D2_CUSFF3,  D2_CUSFF4, D2_CUSFF5, D2_TIPO,   D2_NFORI,
          D2_SERIORI, D2_ITEMORI, F4_ESTOQUE,SD2.R_E_C_N_O_
     from SD2### SD2 (nolock), SF4### SF4 (nolock)
    where D2_FILIAL      = @cFil_SD2
      and D2_COD between @IN_MV_PAR01 and @IN_MV_PAR02
      and F4_FILIAL      = @cFil_SF4
      and F4_PODER3      = 'R'
      and F4_CODIGO      = D2_TES
      and SD2.D_E_L_E_T_ = ' '
      and SF4.D_E_L_E_T_ = ' '
   order by F4_PODER3 desc
   for read only
   /* ------------------------------------------------------------------------------------------------------------------
      Abrindo e movimentando-se pelo Cursor
      ------------------------------------------------------------------------------------------------------------------ */
   open CUR_SD2

   fetch CUR_SD2 into @cD2_CLIENTE, @cD2_LOJA,   @cD2_COD,     @cD2_LOCAL,   @cD2_SEGUM,  @cD2_DOC,    @cD2_SERIE,
                      @dD2_EMISSAO, @nD2_QUANT,  @nD2_PRCVEN,  @cD2_TES,     @cF4_PODER3, @cD2_UM,     @nD2_QTSEGUM,
                      @cD2_IDENTB6, @cD2_NUMSEQ, @nD2_CUSTO1,  @nD2_CUSTO2,  @nD2_CUSTO3, @nD2_CUSTO4, @nD2_CUSTO5,
                      @nD2_CUSFF1,  @nD2_CUSFF2, @nD2_CUSFF3,  @nD2_CUSFF4,  @nD2_CUSFF5, @cD2_TIPO,   @cD2_NFORI,
                      @cD2_SERIORI, @cD2_ITEMORI, @cF4_ESTOQUE,@iSD2_RECNO

   while @@Fetch_Status = 0 begin
      select @nContador = @nContador + 1
      select @cXB6_TPCF  = ''
      select @cXB6_TIPO  = ''
      select @cXB6_IDENT = ''
      select @cXB6_IDENTB6 = ' '
      select @cB6_IDENTB6 = ' '
      select @iRecnoAux = Null
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_TIPO
         ---------------------------------------------------------------------------------------------- */
      If @cF4_PODER3 = 'R' select @cXB6_TIPO = 'E'
      else select @cXB6_TIPO = 'D'
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_TPCF
         ---------------------------------------------------------------------------------------------- */
      If @cD2_TIPO = 'B' select @cXB6_TPCF = 'F'
      else If @cD2_TIPO in ('N','C') select @cXB6_TPCF = 'C'
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_IDENT
         ---------------------------------------------------------------------------------------------- */
      If @cD2_IDENTB6 = ' ' select @cXB6_IDENT = @cD2_NUMSEQ
      else select @cXB6_IDENT = @cD2_IDENTB6
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_IDENTB6
         ---------------------------------------------------------------------------------------------- */
      if @cD2_TIPO in ( 'C','I','P') begin

         select @iRecnoAux = Min(R_E_C_N_O_)
            from SD2###
            Where D2_FILIAL  = @cFil_SD2
            and D2_DOC     = @cD2_NFORI
            and D2_SERIE   = @cD2_SERIORI
            and D2_CLIENTE = @cD2_CLIENTE
            and D2_LOJA    = @cD2_LOJA
            and D2_COD     = @cD2_COD
            and D2_ITEM    = @cD2_ITEMORI
            and D_E_L_E_T_ = ' '

         If @iRecnoAux is not Null begin
            select @cB6_IDENTB6 = D2_NUMSEQ
               from SD2###
               Where R_E_C_N_O_  = @iRecnoAux

            select @cXB6_IDENTB6 = @cB6_IDENTB6
         end
      end

      select @iRecnoSB6 = NULL
      select @iRecnoSB6 = Max(R_E_C_N_O_)
      from SB6###

      if (@iRecnoSB6 is null or @iRecnoSB6 = 0) select  @iRecnoSB6 = 1
      else select @iRecnoSB6 = @iRecnoSB6 + 1

      If @nContador = 1 begin
         begin Tran
         select @nContador = @nContador
      End

      /* ---------------------------------------------------------------------------------------------
         Insercao no SB6
         --------------------------------------------------------------------------------------------- */
      insert into SB6### ( B6_FILIAL,   B6_CLIFOR,  B6_LOJA,    B6_PRODUTO, B6_LOCAL,  B6_SEGUM,
                           B6_DOC,      B6_SERIE,   B6_EMISSAO, B6_QUANT,   B6_PRUNIT, B6_TES,
                           B6_TIPO,     B6_DTDIGIT, B6_UM,      B6_QTSEGUM, B6_IDENT,  B6_CUSTO1,
                           B6_CUSTO2,   B6_CUSTO3,  B6_CUSTO4,  B6_CUSTO5,  B6_CUSFF1, B6_CUSFF2,
                           B6_CUSFF3,   B6_CUSFF4,  B6_CUSFF5,  B6_PODER3,  B6_SALDO,  B6_TPCF,
                           B6_IDENTB6,   B6_ESTOQUE, R_E_C_N_O_ )
                  values ( @cFil_SB6,   @cD2_CLIENTE, @cD2_LOJA,    @cD2_COD,     @cD2_LOCAL,    @cD2_SEGUM,
                           @cD2_DOC,    @cD2_SERIE,   @dD2_EMISSAO, @nD2_QUANT,   @nD2_PRCVEN,   @cD2_TES,
                           @cXB6_TIPO,  @dD2_EMISSAO, @cD2_UM,      @nD2_QTSEGUM, @cXB6_IDENT,   @nD2_CUSTO1,
                           @nD2_CUSTO2, @nD2_CUSTO3,  @nD2_CUSTO4,  @nD2_CUSTO5,  @nD2_CUSFF1,   @nD2_CUSFF2,
                           @nD2_CUSFF3, @nD2_CUSFF4,  @nD2_CUSFF5,  @cF4_PODER3,	@nD2_QUANT,    @cXB6_TPCF,
                           @cXB6_IDENTB6,@cF4_ESTOQUE, @iRecnoSB6 )
      /* -------------------------------------------------------------------------------------------
         Preenchendo numero de identificação do itens de saída
         ------------------------------------------------------------------------------------------- */
      if @cD2_IDENTB6 = ' '
         update SD2###
            set D2_IDENTB6 = @cD2_NUMSEQ
            where R_E_C_N_O_ = @iSD2_RECNO



      fetch CUR_SD2 into @cD2_CLIENTE, @cD2_LOJA,   @cD2_COD,     @cD2_LOCAL,   @cD2_SEGUM,  @cD2_DOC,    @cD2_SERIE,
                         @dD2_EMISSAO, @nD2_QUANT,  @nD2_PRCVEN,  @cD2_TES,     @cF4_PODER3, @cD2_UM,     @nD2_QTSEGUM,
                         @cD2_IDENTB6, @cD2_NUMSEQ, @nD2_CUSTO1,  @nD2_CUSTO2,  @nD2_CUSTO3, @nD2_CUSTO4, @nD2_CUSTO5,
                         @nD2_CUSFF1,  @nD2_CUSFF2, @nD2_CUSFF3,  @nD2_CUSFF4,  @nD2_CUSFF5, @cD2_TIPO,   @cD2_NFORI,
                         @cD2_SERIORI, @cD2_ITEMORI, @cF4_ESTOQUE,@iSD2_RECNO

      If @nContador > 1 begin
         Commit Tran
         select @nContador = 0
      End
   end

   close CUR_SD2
   deallocate CUR_SD2
   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End
   /* ------------------------------------------------------------------------------------------------------------------
      Verifica no arquivo de notas fiscais de saida se existe algum
      item referente a poder de terceiros - remessa  - 5
      ------------------------------------------------------------------------------------------------------------------ */
   select @nContador = 0
   declare CUR_SD1 insensitive cursor for
   select D1_FORNECE, D1_LOJA,	 D1_COD,      D1_LOCAL,  D1_SEGUM,  D1_DOC,     D1_SERIE,
          D1_EMISSAO, D1_QUANT,   D1_TES,     F4_PODER3, D1_UM,     D1_QTSEGUM, D1_VUNIT,
          D1_IDENTB6, D1_NUMSEQ,  D1_CUSTO,   D1_CUSTO2, D1_CUSTO3, D1_CUSTO4,  D1_CUSTO5,
          D1_CUSFF1,  D1_CUSFF2,  D1_CUSFF3,  D1_CUSFF4, D1_CUSFF5, D1_TIPO,    D1_NFORI,
          D1_SERIORI, D1_ITEMORI, D1_DTDIGIT, F4_ESTOQUE,    SD1.R_E_C_N_O_
        from SD1### SD1 (nolock), SF4### SF4 (nolock)
       where D1_FILIAL 	        = @cFil_SD1
         and D1_COD between @IN_MV_PAR01 and @IN_MV_PAR02
         and F4_FILIAL          = @cFil_SF4
         and F4_CODIGO          = D1_TES
         and F4_PODER3          = 'R'
         and SD1.D_E_L_E_T_     = ' '
         and SF4.D_E_L_E_T_     = ' '
   order by F4_PODER3 desc
   for read only

   /* ------------------------------------------------------------------------------------------------------------------
      Abrindo e movimentando-se pelo Cursor
      ------------------------------------------------------------------------------------------------------------------ */
   open CUR_SD1

   fetch CUR_SD1 into @cD1_FORNECE, @cD1_LOJA,    @cD1_COD,     @cD1_LOCAL,   @cD1_SEGUM,  @cD1_DOC,     @cD1_SERIE,
                      @dD1_EMISSAO, @nD1_QUANT,   @cD1_TES,     @cF4_PODER3,  @cD1_UM,     @nD1_QTSEGUM, @nD1_VUNIT,
                      @cD1_IDENTB6, @cD1_NUMSEQ,  @nD1_CUSTO,   @nD1_CUSTO2,  @nD1_CUSTO3, @nD1_CUSTO4,  @nD1_CUSTO5,
                      @nD1_CUSFF1,  @nD1_CUSFF2,  @nD1_CUSFF3,  @nD1_CUSFF4,  @nD1_CUSFF5, @cD1_TIPO,    @cD1_NFORI,
                      @cD1_SERIORI, @cD1_ITEMORI, @dD1_DTDIGIT, @cF4_ESTOQUE, @iSD1_RECNO

   while @@Fetch_Status = 0 begin
      select @nContador = @nContador + 1
      select @cXB6_TPCF  = ''
      select @cXB6_TIPO  = ''
      select @cXB6_IDENT = ''
      select @cXB6_IDENTB6 = ' '
      select @cB6_IDENTB6 = ' '
      select @iRecnoAux = Null
      select @cB6_CLIPROP = ' '
      Select @cB6_LJCLIPR = ' '
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_TIPO
         ---------------------------------------------------------------------------------------------- */
      If @cF4_PODER3 = 'R' select @cXB6_TIPO = 'D'
      else select @cXB6_TIPO = 'E'
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_TPCF
         ---------------------------------------------------------------------------------------------- */
      If @cD1_TIPO = 'B' select @cXB6_TPCF = 'C'
      else If @cD1_TIPO = 'N' select @cXB6_TPCF = 'F'
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_IDENT
         ---------------------------------------------------------------------------------------------- */
      If @cD1_IDENTB6 = ' ' select @cXB6_IDENT = @cD1_NUMSEQ
      else select @cXB6_IDENT = @cD1_IDENTB6
      /* ----------------------------------------------------------------------------------------------
         Tratamento p/ gravacao do B6_IDENTB6
         ---------------------------------------------------------------------------------------------- */
      if @cD1_TIPO in ( 'C','I','P') begin

         select @iRecnoAux = Min(R_E_C_N_O_)
            from SD1###
            Where D1_FILIAL  = @cFil_SD1
               and D1_DOC     = @cD1_NFORI
               and D1_SERIE   = @cD1_SERIORI
               and D1_FORNECE = @cD1_FORNECE
               and D1_LOJA    = @cD1_LOJA
               and D1_COD     = @cD1_COD
               and D1_ITEM    = @cD1_ITEMORI
               and D_E_L_E_T_ = ' '

         If @iRecnoAux is not Null begin
            select @cB6_IDENTB6 = D1_NUMSEQ
               from SD1###
               Where R_E_C_N_O_  = @iRecnoAux

            select @cXB6_IDENTB6 = @cB6_IDENTB6
         end
      end
      ##FIELDP01( 'SF1.F1_CLIPROP;F1_LJCLIPR' )
         select @cB6_CLIPROP = F1_CLIPROP, @cB6_LJCLIPR = F1_LJCLIPR
            from SF1###
            where F1_FILIAL = @cFil_SD1
               and F1_DOC	= @cD1_DOC
               and F1_SERIE  = @cD1_SERIE
               and F1_FORNECE= @cD1_FORNECE
               and F1_LOJA   = @cD1_LOJA
               and D_E_L_E_T_ = ' '
      ##ENDFIELDP01
      select @iRecnoSB6 = NULL
      select @iRecnoSB6 = Max(R_E_C_N_O_)
      from SB6###

      if (@iRecnoSB6 is null or @iRecnoSB6 = 0) select  @iRecnoSB6 = 1
      else select @iRecnoSB6 = @iRecnoSB6 + 1

      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End
      /* ----------------------------------------------------------------------------------------------
         Insere saldo no SB6
         ----------------------------------------------------------------------------------------------- */
      insert into SB6### ( B6_FILIAL,  B6_CLIFOR,    B6_LOJA,     B6_PRODUTO,   B6_LOCAL,   B6_SEGUM,
                           B6_DOC,     B6_SERIE,     B6_EMISSAO,  B6_QUANT,     B6_PRUNIT,  B6_TES,
                           B6_TIPO,    B6_DTDIGIT,   B6_UM,       B6_QTSEGUM,   B6_IDENT,   B6_CUSTO1,
                           B6_CUSTO2,  B6_CUSTO3,    B6_CUSTO4,   B6_CUSTO5,    B6_CUSFF1,  B6_CUSFF2,
                           B6_CUSFF3,  B6_CUSFF4,    B6_CUSFF5,   B6_PODER3,    B6_SALDO,   B6_TPCF,
                           B6_IDENTB6, B6_ESTOQUE,
                     ##FIELDP02( 'SB6.B6_CLIPROP;B6_LJCLIPR' )
                     B6_CLIPROP, B6_LJCLIPR,
                     ##ENDFIELDP02
                     R_E_C_N_O_ )
                  values ( @cFil_SB6,    @cD1_FORNECE, @cD1_LOJA,   @cD1_COD,     @cD1_LOCAL,   @cD1_SEGUM,
                           @cD1_DOC,     @cD1_SERIE,   @dD1_EMISSAO,@nD1_QUANT,   @nD1_VUNIT,   @cD1_TES,
                           @cXB6_TIPO,   @dD1_DTDIGIT, @cD1_UM,     @nD1_QTSEGUM, @cXB6_IDENT,  @nD1_CUSTO,
                           @nD1_CUSTO2,  @nD1_CUSTO3,  @nD1_CUSTO4, @nD1_CUSTO5,  @nD1_CUSFF1,  @nD1_CUSFF2,
                           @nD1_CUSFF3,  @nD1_CUSFF4,  @nD1_CUSFF5, @cF4_PODER3,  @nD1_QUANT,   @cXB6_TPCF,
                           @cXB6_IDENTB6,@cF4_ESTOQUE,
                     ##FIELDP03( 'SB6.B6_CLIPROP;B6_LJCLIPR' )
                     @cB6_CLIPROP, @cB6_LJCLIPR,
                     ##ENDFIELDP03
                     @iRecnoSB6 )

      /* -------------------------------------------------------------------------------------------------------------
         Preenchendo numero de identificação do itens de saída
         ------------------------------------------------------------------------------------------------------------- */
      if @cD1_IDENTB6 = ' '
         update SD1###
            set D1_IDENTB6 = @cD1_NUMSEQ
            where R_E_C_N_O_ = @iSD1_RECNO

      fetch CUR_SD1 into @cD1_FORNECE, @cD1_LOJA,    @cD1_COD,     @cD1_LOCAL,   @cD1_SEGUM,  @cD1_DOC,     @cD1_SERIE,
                         @dD1_EMISSAO, @nD1_QUANT,   @cD1_TES,     @cF4_PODER3,  @cD1_UM,     @nD1_QTSEGUM, @nD1_VUNIT,
                         @cD1_IDENTB6, @cD1_NUMSEQ,  @nD1_CUSTO,   @nD1_CUSTO2,  @nD1_CUSTO3, @nD1_CUSTO4, @nD1_CUSTO5,
                         @nD1_CUSFF1,  @nD1_CUSFF2,  @nD1_CUSFF3,  @nD1_CUSFF4,  @nD1_CUSFF5, @cD1_TIPO,    @cD1_NFORI,
                         @cD1_SERIORI, @cD1_ITEMORI, @dD1_DTDIGIT, @cF4_ESTOQUE, @iSD1_RECNO

      If @nContador > 1 begin
         Commit Tran
         select @nContador = 0
      End
   end

   close CUR_SD1
   deallocate CUR_SD1

   If @nContador > 0 begin
      commit Tran
      select @iTranCount = 0
   End
   /* ------------------------------------------------------------------------------------------
      Verifica no arquivo de notas fiscais de saida se existe
      algum item referente a poder de terceiros - devolucao   - 7
      ------------------------------------------------------------------------------------------ */
   select @nContador = 0
   declare CUR_SD2DE insensitive cursor for
   select D2_CLIENTE, D2_LOJA,	 D2_COD,    D2_LOCAL,  D2_SEGUM,  D2_DOC,    D2_SERIE,
          D2_EMISSAO, D2_QUANT,  D2_PRCVEN, D2_TES,    F4_PODER3, D2_UM,     D2_QTSEGUM,
          D2_IDENTB6, D2_NUMSEQ, D2_CUSTO1, D2_CUSTO2, D2_CUSTO3, D2_CUSTO4, D2_CUSTO5,
          D2_CUSFF1,  D2_CUSFF2, D2_CUSFF3, D2_CUSFF4, D2_CUSFF5, D2_TIPO,   F4_ESTOQUE,
          SD2.R_E_C_N_O_
     from SD2### SD2 (nolock), SF4### SF4 (nolock)
    where D2_FILIAL      = @cFil_SD2
      and D2_COD between @IN_MV_PAR01 and @IN_MV_PAR02
      and F4_FILIAL      = @cFil_SF4
      and F4_PODER3      = 'D'
      and F4_CODIGO      = D2_TES
      and SD2.D_E_L_E_T_ = ' '
      and SF4.D_E_L_E_T_ = ' '
   order by F4_PODER3 desc
   for read only
   /* ------------------------------------------------------------------------------------------------------------------
      Abrindo e movimentando-se pelo Cursor
      ------------------------------------------------------------------------------------------------------------------ */
   open CUR_SD2DE

   fetch CUR_SD2DE into @cD2_CLIENTE, @cD2_LOJA, @cD2_COD,    @cD2_LOCAL,  @cD2_SEGUM,  @cD2_DOC,    @cD2_SERIE,
                      @dD2_EMISSAO, @nD2_QUANT,  @nD2_PRCVEN, @cD2_TES,    @cF4_PODER3, @cD2_UM,     @nD2_QTSEGUM,
                      @cD2_IDENTB6, @cD2_NUMSEQ, @nD2_CUSTO1, @nD2_CUSTO2, @nD2_CUSTO3, @nD2_CUSTO4, @nD2_CUSTO5,
                      @nD2_CUSFF1,  @nD2_CUSFF2, @nD2_CUSFF3, @nD2_CUSFF4, @nD2_CUSFF5, @cD2_TIPO,   @cF4_ESTOQUE,
                      @iSD2_RECNO

   while @@Fetch_Status = 0 begin
      select @nContador = @nContador + 1
      select @cXB6_TPCF   = ''
      select @cXB6_TIPO   = ''
      select @cXB6_IDENT  = ''
      select @cXB6_PODER3 = ''
      select @cXB6_UENT   = ''
      select @cIdentSB6   = ''
      select @nXB6_SALDO  = 0
      select @nXXB6_SALDO = 0
      select @cXB6_ESTOQUE = ''
      select @nXB6_QUANT  = 0
      select @nXB6_CUSTO1 = 0
      select @nXB6_CUSTO2 = 0
      select @nXB6_CUSTO3 = 0
      select @nXB6_CUSTO4 = 0
      select @nXB6_CUSTO5 = 0
      select @nXB6_CUSFF1 = 0
      select @nXB6_CUSFF2 = 0
      select @nXB6_CUSFF3 = 0
      select @nXB6_CUSFF4 = 0
      select @nXB6_CUSFF5 = 0

      /* ----------------------------------------------------------------------------------------------
         Verifica se existe no SB6
         ---------------------------------------------------------------------------------------------- */
      select @iRecnoSB6  = null
      select @iRecnoSB6  = MIN(R_E_C_N_O_)
         from SB6###
         where B6_FILIAL  = @cFil_SB6
         and B6_IDENT   = @cD2_IDENTB6
         and B6_PRODUTO = @cD2_COD
         and D_E_L_E_T_ = ' '

      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End
      select @nAtend    = 0
      select @nB6_C1TOT = 0
      select @nB6_C2TOT = 0
      select @nB6_C3TOT = 0
      select @nB6_C4TOT = 0
      select @nB6_C5TOT = 0
      select @nB6_CFF1TOT = 0
      select @nB6_CFF2TOT = 0
      select @nB6_CFF3TOT = 0
      select @nB6_CFF4TOT = 0
      select @nB6_CFF5TOT = 0
      If @iRecnoSB6 is not null begin
         select @cXB6_IDENT = B6_IDENT, @cXB6_PODER3 = B6_PODER3,
                  @nXB6_SALDO = B6_SALDO, @cXB6_UENT = B6_UENT,
                  @cXB6_ESTOQUE = B6_ESTOQUE, @nXB6_QUANT = B6_QUANT,
                  @nXB6_CUSTO1 = B6_CUSTO1, @nXB6_CUSTO2 = B6_CUSTO2,
                  @nXB6_CUSTO3 = B6_CUSTO3, @nXB6_CUSTO4 = B6_CUSTO4,
                  @nXB6_CUSTO5 = B6_CUSTO5, @nXB6_CUSFF1 = B6_CUSFF1,
                  @nXB6_CUSFF2 = B6_CUSFF2, @nXB6_CUSFF3 = B6_CUSFF3,
                  @nXB6_CUSFF4 = B6_CUSFF4, @nXB6_CUSFF5 = B6_CUSFF5
            from SB6###
            where R_E_C_N_O_ = @iRecnoSB6

         /* ----------------------------------------------------------------------------------------------
            Tratamento p/ gravacao do B6_TIPO
            ---------------------------------------------------------------------------------------------- */
         If @cF4_PODER3 = 'R' select @cXB6_TIPO = 'E'
         else select @cXB6_TIPO = 'D'
         /* ----------------------------------------------------------------------------------------------
            Tratamento p/ gravacao do B6_TPCF
            ---------------------------------------------------------------------------------------------- */
         If @cD2_TIPO = 'B' select @cXB6_TPCF = 'F'
         else If @cD2_TIPO = 'N' select @cXB6_TPCF = 'C'
         /* ----------------------------------------------------------------------------------------------
            Gravacao do saldo - SB6
            ---------------------------------------------------------------------------------------------- */
            select @cIdentSB6 = @cXB6_IDENT
            If @cXB6_PODER3 = 'R' begin
               UpDate SB6###
                  Set B6_SALDO = ( @nXB6_SALDO - @nD2_QUANT)
                  Where R_E_C_N_O_ = @iRecnoSB6
               
               select @nAtend    = 0
               select @nB6_C1TOT = 0
               select @nB6_C2TOT = 0
               select @nB6_C3TOT = 0
               select @nB6_C4TOT = 0
               select @nB6_C5TOT = 0
               select @nB6_CFF1TOT = 0
               select @nB6_CFF2TOT = 0
               select @nB6_CFF3TOT = 0
               select @nB6_CFF4TOT = 0
               select @nB6_CFF5TOT = 0
               /* -------------------------------------------------------------------
                  @nXXB6_SALDO - Auxiliar
               ---------------------------------------------------------------------- */
               Select @nXXB6_SALDO = ( @nXB6_SALDO - @nD2_QUANT)
               If @nXXB6_SALDO <= 0 begin
                  UpDate SB6###
                     Set B6_ATEND = 'S'
                     Where R_E_C_N_O_ = @iRecnoSB6

                  /*
                  Tratamento para resgatar custo total já devolvido
                  */
                  select @nAtend = 1
                  Select @nB6_C1TOT = Sum(B6_CUSTO1), @nB6_C2TOT = Sum(B6_CUSTO2), 
                         @nB6_C3TOT = Sum(B6_CUSTO3), @nB6_C4TOT = Sum(B6_CUSTO4), 
                         @nB6_C5TOT = Sum(B6_CUSTO5), @nB6_CFF1TOT = Sum(B6_CUSFF1), 
                         @nB6_CFF2TOT = Sum(B6_CUSFF2), @nB6_CFF3TOT = Sum(B6_CUSFF3), 
                         @nB6_CFF4TOT = Sum(B6_CUSFF4), @nB6_CFF5TOT = Sum(B6_CUSFF5)
                  From SB6###
                  Where B6_FILIAL  = @cFil_SB6
                    And B6_IDENT   = @cD2_IDENTB6
                    And B6_PRODUTO = @cD2_COD
                    And B6_PODER3  = 'D'
                    And D_E_L_E_T_ = ' '
                  
                  select @nB6_C1TOT = isnull(@nB6_C1TOT, 0)
                  select @nB6_C2TOT = isnull(@nB6_C2TOT, 0)
                  select @nB6_C3TOT = isnull(@nB6_C3TOT, 0)
                  select @nB6_C4TOT = isnull(@nB6_C4TOT, 0)
                  select @nB6_C5TOT = isnull(@nB6_C5TOT, 0)
                  select @nB6_CFF1TOT = isnull(@nB6_CFF1TOT, 0)
                  select @nB6_CFF2TOT = isnull(@nB6_CFF2TOT, 0)
                  select @nB6_CFF3TOT = isnull(@nB6_CFF3TOT, 0)
                  select @nB6_CFF4TOT = isnull(@nB6_CFF4TOT, 0)
                  select @nB6_CFF5TOT = isnull(@nB6_CFF5TOT, 0)

               end
               If @cXB6_UENT < @dD2_EMISSAO begin
                  UpDate SB6###
                     Set B6_UENT = @dD2_EMISSAO
                     Where R_E_C_N_O_ = @iRecnoSB6
               end
            end
            /* ---------------------------------------------------------------------------------------------
               Insercao no SB6
               --------------------------------------------------------------------------------------------- */
            if @cIdentSB6 <> ' ' begin

               // Obtendo os custos para a movimentacao
               if @nXB6_SALDO < @nD2_QUANT begin
                  select @nD2_QUANT = @nXB6_SALDO
               end
               IF @cF4_PODER3 = 'D'
               BEGIN
                  SELECT @nXB6_CCOMP1 = Sum (SD1.D1_CUSTO), @nXB6_CCOMP2 = SUm (SD1.D1_CUSTO2) ,
                  @nXB6_CCOMP3 = SUM (SD1.D1_CUSTO3), @nXB6_CCOMP4= SUM (SD1.D1_CUSTO4), @nXB6_CCOMP5 = SUM(SD1.D1_CUSTO5) ,
                  @nXB6_CFFCOM1 = SUM (SD1.D1_CUSFF1), @nXB6_CFFCOM2 = SUM (SD1.D1_CUSFF2), @nXB6_CFFCOM3 = SUM(SD1.D1_CUSFF3) ,
                  @nXB6_CFFCOM4 = SUM (SD1.D1_CUSFF4), @nXB6_CFFCOM5 = SUM (SD1.D1_CUSFF5)
                  FROM SD1### SD1
                  INNER JOIN SB6### SB6
                  ON
                     SB6.B6_FILIAL= @cFil_SB6 AND
                     SB6.B6_IDENT = SD1.D1_IDENTB6 AND
                     SB6.D_E_L_E_T_=' '
                  INNER JOIN SB6### ORI
                  ON
                     ORI.B6_FILIAL= @cFil_SB6 AND
                     ORI.B6_DOC = SD1.D1_NFORI AND
                     ORI.B6_SERIE = SD1.D1_SERIORI AND
                     ORI.B6_CLIFOR = SD1.D1_FORNECE AND
                     ORI.B6_LOJA = SD1.D1_LOJA AND
                     ORI.B6_PRODUTO = SD1.D1_COD AND
                     ORI.B6_IDENT = @cD2_IDENTB6 AND
                     ORI.B6_PRODUTO = @cD2_COD AND
                     ORI.B6_PODER3 = 'R' AND
                     ORI.D_E_L_E_T_=' '
                  WHERE
                     SD1.D1_FILIAL= @cFil_SD1 AND
                     SD1.D_E_L_E_T_=' '
               END
               ELSE
               BEGIN
                  select @nXB6_CCOMP1 = 0
                  select @nXB6_CCOMP2 = 0
                  select @nXB6_CCOMP3 = 0
                  select @nXB6_CCOMP4 = 0
                  select @nXB6_CCOMP5 = 0
                  select @nXB6_CFFCOM1 = 0
                  select @nXB6_CFFCOM2 = 0
                  select @nXB6_CFFCOM3 = 0
                  select @nXB6_CFFCOM4 = 0
                  select @nXB6_CFFCOM5 = 0
               END
               If @nXB6_CCOMP1 is null select @nXB6_CCOMP1 = 0
               If @nXB6_CCOMP2 is null select @nXB6_CCOMP2 = 0
               If @nXB6_CCOMP3 is null select @nXB6_CCOMP3 = 0
               If @nXB6_CCOMP4 is null select @nXB6_CCOMP4 = 0
               If @nXB6_CCOMP5 is null select @nXB6_CCOMP5 = 0
               If @nXB6_CFFCOM1 is null select @nXB6_CFFCOM1 = 0
               If @nXB6_CFFCOM2 is null select @nXB6_CFFCOM2 = 0
               If @nXB6_CFFCOM3 is null select @nXB6_CFFCOM3 = 0
               If @nXB6_CFFCOM4 is null select @nXB6_CFFCOM4 = 0
               If @nXB6_CFFCOM5 is null select @nXB6_CFFCOM5 = 0

               If @nAtend = 1
                  Begin
                  select @nD2_CUSTO1 = @nXB6_CUSTO1 + @nXB6_CCOMP1 - @nB6_C1TOT
                  select @nD2_CUSTO2 = @nXB6_CUSTO2 + @nXB6_CCOMP2 - @nB6_C2TOT
                  select @nD2_CUSTO3 = @nXB6_CUSTO3 + @nXB6_CCOMP3 - @nB6_C3TOT
                  select @nD2_CUSTO4 = @nXB6_CUSTO4 + @nXB6_CCOMP4 - @nB6_C4TOT
                  select @nD2_CUSTO5 = @nXB6_CUSTO5 + @nXB6_CCOMP5 - @nB6_C5TOT

                  select @nD2_CUSFF1 = @nXB6_CUSFF1 + @nXB6_CFFCOM1 - @nB6_CFF1TOT
                  select @nD2_CUSFF2 = @nXB6_CUSFF2 + @nXB6_CFFCOM2 - @nB6_CFF2TOT
                  select @nD2_CUSFF3 = @nXB6_CUSFF3 + @nXB6_CFFCOM3 - @nB6_CFF3TOT
                  select @nD2_CUSFF4 = @nXB6_CUSFF4 + @nXB6_CFFCOM4 - @nB6_CFF4TOT
                  select @nD2_CUSFF5 = @nXB6_CUSFF5 + @nXB6_CFFCOM5 - @nB6_CFF5TOT
                  End
               Else
                  Begin
                  select @nD2_CUSTO1 = (@nXB6_CUSTO1  + @nXB6_CCOMP1) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSTO2 = (@nXB6_CUSTO2  + @nXB6_CCOMP2) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSTO3 = (@nXB6_CUSTO3  + @nXB6_CCOMP3) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSTO4 = (@nXB6_CUSTO4  + @nXB6_CCOMP4) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSTO5 = (@nXB6_CUSTO5  + @nXB6_CCOMP5) * (@nD2_QUANT / @nXB6_QUANT)

                  select @nD2_CUSFF1 = (@nXB6_CUSFF1  + @nXB6_CFFCOM1) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSFF2 = (@nXB6_CUSFF2  + @nXB6_CFFCOM2) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSFF3 = (@nXB6_CUSFF3  + @nXB6_CFFCOM3) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSFF4 = (@nXB6_CUSFF4  + @nXB6_CFFCOM4) * (@nD2_QUANT / @nXB6_QUANT)
                  select @nD2_CUSFF5 = (@nXB6_CUSFF5  + @nXB6_CFFCOM5) * (@nD2_QUANT / @nXB6_QUANT)
                  End

               select @iRecnoSB6 = NULL
               select @iRecnoSB6 = Max(R_E_C_N_O_)
                  from SB6###

               if (@iRecnoSB6 is null or @iRecnoSB6 = 0) select  @iRecnoSB6 = 1
               else select @iRecnoSB6 = @iRecnoSB6 + 1

               IF @cF4_PODER3 = 'D'
               BEGIN
                  select @nB6_PRUNIT  = @nD2_PRCVEN
               END
               ELSE
               BEGIN
                  select @nB6_PRUNIT = B6_PRUNIT
                  from SB6###
                  where B6_FILIAL = @cFil_SB6
                  and B6_IDENT = @cIdentSB6
                  and B6_PRODUTO = @cD2_COD
                  and B6_PODER3 = 'R'
                  and D_E_L_E_T_= ' '
               END

               insert into SB6### ( B6_FILIAL,    B6_CLIFOR,    B6_LOJA,    B6_PRODUTO,  B6_LOCAL,  B6_SEGUM,
                                    B6_DOC,       B6_SERIE,     B6_EMISSAO, B6_QUANT,    B6_PRUNIT, B6_TES,
                                    B6_TIPO,      B6_DTDIGIT,   B6_UM,      B6_QTSEGUM,  B6_IDENT,  B6_CUSTO1,
                                    B6_CUSTO2,    B6_CUSTO3,    B6_CUSTO4,  B6_CUSTO5,   B6_CUSFF1, B6_CUSFF2,
                                    B6_CUSFF3,    B6_CUSFF4,    B6_CUSFF5,  B6_PODER3,   B6_UENT,   B6_TPCF,
                                    B6_ESTOQUE,   R_E_C_N_O_ )
                           values ( @cFil_SB6,    @cD2_CLIENTE, @cD2_LOJA,    @cD2_COD,     @cD2_LOCAL,	@cD2_SEGUM,
                                    @cD2_DOC,     @cD2_SERIE,   @dD2_EMISSAO, @nD2_QUANT,   @nB6_PRUNIT, @cD2_TES,
                                    @cXB6_TIPO,   @dD2_EMISSAO, @cD2_UM,      @nD2_QTSEGUM, @cIdentSB6,  @nD2_CUSTO1,
                                    @nD2_CUSTO2,  @nD2_CUSTO3,  @nD2_CUSTO4,  @nD2_CUSTO5,  @nD2_CUSFF1, @nD2_CUSFF2,
                                    @nD2_CUSFF3,  @nD2_CUSFF4,  @nD2_CUSFF5,  'D',         '        ',   @cXB6_TPCF,
                                    @cXB6_ESTOQUE, @iRecnoSB6 )
               end

            end

         fetch CUR_SD2DE into @cD2_CLIENTE, @cD2_LOJA,   @cD2_COD,    @cD2_LOCAL,  @cD2_SEGUM,  @cD2_DOC,    @cD2_SERIE,
                              @dD2_EMISSAO, @nD2_QUANT,  @nD2_PRCVEN, @cD2_TES,    @cF4_PODER3, @cD2_UM,     @nD2_QTSEGUM,
                              @cD2_IDENTB6, @cD2_NUMSEQ, @nD2_CUSTO1, @nD2_CUSTO2, @nD2_CUSTO3, @nD2_CUSTO4, @nD2_CUSTO5,
                              @nD2_CUSFF1,  @nD2_CUSFF2, @nD2_CUSFF3, @nD2_CUSFF4, @nD2_CUSFF5, @cD2_TIPO,   @cF4_ESTOQUE,
                              @iSD2_RECNO
         If @nContador > 1 begin
            Commit Tran
            select @nContador = 0
         End
      end

      close CUR_SD2DE
      deallocate CUR_SD2DE
      If @nContador > 0 begin
         Commit Tran
         select @iTranCount = 0
      End
      /* ------------------------------------------------------------------------------------------
         Verifica no arquivo de notas fiscais de entrada se existe
         algum item referente a poder de terceiros - devolucao -9
         ------------------------------------------------------------------------------------------ */
      select @nContador = 0
      declare CUR_SD1DE insensitive cursor for
      select D1_FORNECE, D1_LOJA,	 D1_COD,    D1_LOCAL,  D1_SEGUM,  D1_DOC,     D1_SERIE,
            D1_EMISSAO, D1_QUANT,  D1_TES,    F4_PODER3, D1_UM,     D1_QTSEGUM, D1_DTDIGIT,
            D1_IDENTB6, D1_NUMSEQ, D1_CUSTO,  D1_CUSTO2, D1_CUSTO3, D1_CUSTO4,  D1_CUSTO5,
            D1_CUSFF1,  D1_CUSFF2, D1_CUSFF3, D1_CUSFF4, D1_CUSFF5, D1_TIPO,    D1_VUNIT,
            F4_ESTOQUE,SD1.R_E_C_N_O_
         from SD1### SD1 (nolock), SF4### SF4 (nolock)
         where D1_FILIAL 	        = @cFil_SD1
            and D1_COD between @IN_MV_PAR01 and @IN_MV_PAR02
            and F4_FILIAL          = @cFil_SF4
            and F4_CODIGO          = D1_TES
            and F4_PODER3          = 'D'
            and SD1.D_E_L_E_T_     = ' '
            and SF4.D_E_L_E_T_     = ' '
      order by F4_PODER3 desc
      for read only
      /* ------------------------------------------------------------------------------------------------------------------
         Abrindo e movimentando-se pelo Cursor
         ------------------------------------------------------------------------------------------------------------------ */
      open CUR_SD1DE

      fetch CUR_SD1DE into @cD1_FORNECE, @cD1_LOJA,   @cD1_COD,    @cD1_LOCAL,  @cD1_SEGUM,  @cD1_DOC,     @cD1_SERIE,
                           @dD1_EMISSAO, @nD1_QUANT,  @cD1_TES,    @cF4_PODER3, @cD1_UM,     @nD1_QTSEGUM, @dD1_DTDIGIT,
                           @cD1_IDENTB6, @cD1_NUMSEQ, @nD1_CUSTO,  @nD1_CUSTO2, @nD1_CUSTO3, @nD1_CUSTO4,  @nD1_CUSTO5,
                           @nD1_CUSFF1,  @nD1_CUSFF2, @nD1_CUSFF3, @nD1_CUSFF4, @nD1_CUSFF5, @cD1_TIPO,    @nD1_VUNIT,
                           @cF4_ESTOQUE,@iSD1_RECNO

      while @@Fetch_Status = 0 begin
         select @nContador = 0
         select @cXB6_TPCF   = ''
         select @cXB6_TIPO   = ''
         select @cXB6_IDENT  = ''
         select @cXB6_PODER3 = ''
         select @cXB6_UENT   = ''
         select @cIdentSB6   = ''
         select @nXB6_SALDO  = 0
         select @nXXB6_SALDO = 0
         select @cXB6_ESTOQUE = ''
         select @nXB6_QUANT  = 0
         select @nXB6_CUSTO1 = 0
         select @nXB6_CUSTO2 = 0
         select @nXB6_CUSTO3 = 0
         select @nXB6_CUSTO4 = 0
         select @nXB6_CUSTO5 = 0
         select @nXB6_CUSFF1 = 0
         select @nXB6_CUSFF2 = 0
         select @nXB6_CUSFF3 = 0
         select @nXB6_CUSFF4 = 0
         select @nXB6_CUSFF5 = 0
         /* ----------------------------------------------------------------------------------------------
            Verifica se existe no SB6
            Tratamento p/ gravacao do B6_IDENT
            ---------------------------------------------------------------------------------------------- */
         select @iRecnoSB6  = null
         select @iRecnoSB6  = MIN(R_E_C_N_O_)
           from SB6###
          where B6_FILIAL  = @cFil_SB6
            and B6_IDENT   = @cD1_IDENTB6
            and B6_PRODUTO = @cD1_COD
            and D_E_L_E_T_ = ' '

         If @nContador = 1 begin
            Begin Tran
            select @nContador = @nContador
         End
         select @nAtend = 0
         select @nB6_C1TOT = 0
         select @nB6_C2TOT = 0
         select @nB6_C3TOT = 0
         select @nB6_C4TOT = 0
         select @nB6_C5TOT = 0
         select @nB6_CFF1TOT = 0
         select @nB6_CFF2TOT = 0
         select @nB6_CFF3TOT = 0
         select @nB6_CFF4TOT = 0
         select @nB6_CFF5TOT = 0

         If @iRecnoSB6 is not null begin
            select @cXB6_IDENT = B6_IDENT, @cXB6_IDENTB6 = B6_IDENTB6, @cXB6_PODER3 = B6_PODER3,
                   @nXB6_SALDO = B6_SALDO, @cXB6_UENT = B6_UENT,
                   @cXB6_ESTOQUE = B6_ESTOQUE, @nXB6_QUANT = B6_QUANT,
                   @nXB6_CUSTO1 = B6_CUSTO1, @nXB6_CUSTO2 = B6_CUSTO2,
                   @nXB6_CUSTO3 = B6_CUSTO3, @nXB6_CUSTO4 = B6_CUSTO4,
                   @nXB6_CUSTO5 = B6_CUSTO5, @nXB6_CUSFF1 = B6_CUSFF1,
                   @nXB6_CUSFF2 = B6_CUSFF2, @nXB6_CUSFF3 = B6_CUSFF3,
                   @nXB6_CUSFF4 = B6_CUSFF4, @nXB6_CUSFF5 = B6_CUSFF5
              from SB6###
             where R_E_C_N_O_ = @iRecnoSB6
            /* ----------------------------------------------------------------------------------------------
               Tratamento p/ gravacao do B6_TIPO
               ---------------------------------------------------------------------------------------------- */
            If @cF4_PODER3 = 'R' select @cXB6_TIPO = 'D'
            else select @cXB6_TIPO = 'E'
            /* ----------------------------------------------------------------------------------------------
               Tratamento p/ gravacao do B6_TPCF
               ---------------------------------------------------------------------------------------------- */
            If @cD1_TIPO = 'B' select @cXB6_TPCF = 'C'
            else If @cD1_TIPO = 'N' select @cXB6_TPCF = 'F'
            /* ----------------------------------------------------------------------------------------------
               Gravacao do saldo - SB6
               ---------------------------------------------------------------------------------------------- */
            select @cIdentSB6 = @cXB6_IDENT
            If @cXB6_PODER3 = 'R' begin
               UpDate SB6###
                  Set B6_SALDO = ( @nXB6_SALDO - @nD1_QUANT)
                  Where R_E_C_N_O_ = @iRecnoSB6
               /* -------------------------------------------------------------------
                  @nXXB6_SALDO - Auxiliar
               ---------------------------------------------------------------------- */
               Select @nXXB6_SALDO = ( @nXB6_SALDO - @nD1_QUANT)

               select @nAtend    = 0
               select @nB6_C1TOT = 0
               select @nB6_C2TOT = 0
               select @nB6_C3TOT = 0
               select @nB6_C4TOT = 0
               select @nB6_C5TOT = 0
               select @nB6_CFF1TOT = 0
               select @nB6_CFF2TOT = 0
               select @nB6_CFF3TOT = 0
               select @nB6_CFF4TOT = 0
               select @nB6_CFF5TOT = 0

               If @nXXB6_SALDO <= 0 begin
                  UpDate SB6###
                     Set B6_ATEND = 'S'
                     Where R_E_C_N_O_ = @iRecnoSB6
                  /*
                  Tratamento para resgatar custo total j? devolvido
                  */
                  select @nAtend = 1
                  Select @nB6_C1TOT = Sum(B6_CUSTO1), @nB6_C2TOT = Sum(B6_CUSTO2), 
                         @nB6_C3TOT = Sum(B6_CUSTO3), @nB6_C4TOT = Sum(B6_CUSTO4), 
                         @nB6_C5TOT = Sum(B6_CUSTO5), @nB6_CFF1TOT = Sum(B6_CUSFF1), 
                         @nB6_CFF2TOT = Sum(B6_CUSFF2), @nB6_CFF3TOT = Sum(B6_CUSFF3), 
                         @nB6_CFF4TOT = Sum(B6_CUSFF4), @nB6_CFF5TOT = Sum(B6_CUSFF5)
                  From SB6###
                  Where B6_FILIAL  = @cFil_SB6
                    And B6_IDENT   = @cD1_IDENTB6
                    And B6_PRODUTO = @cD1_COD
                    And B6_PODER3  = 'D'
                    And D_E_L_E_T_ = ' '
                  
                  select @nB6_C1TOT = isnull(@nB6_C1TOT, 0)
                  select @nB6_C2TOT = isnull(@nB6_C2TOT, 0)
                  select @nB6_C3TOT = isnull(@nB6_C3TOT, 0)
                  select @nB6_C4TOT = isnull(@nB6_C4TOT, 0)
                  select @nB6_C5TOT = isnull(@nB6_C5TOT, 0)
                  select @nB6_CFF1TOT = isnull(@nB6_CFF1TOT, 0)
                  select @nB6_CFF2TOT = isnull(@nB6_CFF2TOT, 0)
                  select @nB6_CFF3TOT = isnull(@nB6_CFF3TOT, 0)
                  select @nB6_CFF4TOT = isnull(@nB6_CFF4TOT, 0)
                  select @nB6_CFF5TOT = isnull(@nB6_CFF5TOT, 0)

               end
               If @cXB6_UENT < @dD1_DTDIGIT begin
                  UpDate SB6###
                     Set B6_UENT = @dD1_DTDIGIT
                     Where R_E_C_N_O_ = @iRecnoSB6
               end
            end

         end
         /* ---------------------------------------------------------------------------------------------
            Insercao no SB6
            --------------------------------------------------------------------------------------------- */
         if @cIdentSB6 <> ' ' begin

            // Obtendo os custos para a movimentacao
            if @nXB6_SALDO < @nD1_QUANT begin
               select @nD1_QUANT = @nXB6_SALDO
            end

            If @nAtend = 1 
               begin
               select @nD1_CUSTO  = @nXB6_CUSTO1 - @nB6_C1TOT
               select @nD1_CUSTO2 = @nXB6_CUSTO2 - @nB6_C2TOT
               select @nD1_CUSTO3 = @nXB6_CUSTO3 - @nB6_C3TOT
               select @nD1_CUSTO4 = @nXB6_CUSTO4 - @nB6_C4TOT
               select @nD1_CUSTO5 = @nXB6_CUSTO5 - @nB6_C5TOT

               select @nD1_CUSFF1 = @nXB6_CUSFF1 - @nB6_CFF1TOT
               select @nD1_CUSFF2 = @nXB6_CUSFF2 - @nB6_CFF2TOT
               select @nD1_CUSFF3 = @nXB6_CUSFF3 - @nB6_CFF3TOT
               select @nD1_CUSFF4 = @nXB6_CUSFF4 - @nB6_CFF4TOT
               select @nD1_CUSFF5 = @nXB6_CUSFF5 - @nB6_CFF5TOT
               end 
            Else 
               begin
               select @nD1_CUSTO  = @nXB6_CUSTO1 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSTO2 = @nXB6_CUSTO2 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSTO3 = @nXB6_CUSTO3 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSTO4 = @nXB6_CUSTO4 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSTO5 = @nXB6_CUSTO5 * (@nD1_QUANT / @nXB6_QUANT)

               select @nD1_CUSFF1 = @nXB6_CUSFF1 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSFF2 = @nXB6_CUSFF2 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSFF3 = @nXB6_CUSFF3 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSFF4 = @nXB6_CUSFF4 * (@nD1_QUANT / @nXB6_QUANT)
               select @nD1_CUSFF5 = @nXB6_CUSFF5 * (@nD1_QUANT / @nXB6_QUANT)
               End

            select @iRecnoSB6 = NULL
            select @iRecnoSB6 = Max(R_E_C_N_O_)
            from SB6###

            if (@iRecnoSB6 is null or @iRecnoSB6 = 0) select  @iRecnoSB6 = 1
            else select @iRecnoSB6 = @iRecnoSB6 + 1


            insert into SB6### ( B6_FILIAL,  B6_CLIFOR,  B6_LOJA,    B6_PRODUTO, B6_LOCAL,  B6_SEGUM,
                                 B6_DOC,     B6_SERIE,   B6_EMISSAO, B6_QUANT,   B6_PRUNIT, B6_TES,
                                 B6_TIPO,    B6_DTDIGIT, B6_UM,      B6_QTSEGUM, B6_IDENT,  B6_CUSTO1,
                                 B6_CUSTO2,  B6_CUSTO3,  B6_CUSTO4,  B6_CUSTO5,  B6_CUSFF1, B6_CUSFF2,
                                 B6_CUSFF3,  B6_CUSFF4,  B6_CUSFF5,  B6_PODER3,  B6_UENT,   B6_TPCF,
                                 B6_ESTOQUE,  B6_IDENTB6, R_E_C_N_O_ )
                        values ( @cFil_SB6,  @cD1_FORNECE, @cD1_LOJA,   @cD1_COD,     @cD1_LOCAL,  @cD1_SEGUM,
                                 @cD1_DOC,   @cD1_SERIE,   @dD1_EMISSAO,@nD1_QUANT,   @nD1_VUNIT,  @cD1_TES,
                                 @cXB6_TIPO, @dD1_DTDIGIT, @cD1_UM,     @nD1_QTSEGUM, @cIdentSB6,  @nD1_CUSTO,
                                 @nD1_CUSTO2,@nD1_CUSTO3,  @nD1_CUSTO4, @nD1_CUSTO5,  @nD1_CUSFF1, @nD1_CUSFF2,
                                 @nD1_CUSFF3,@nD1_CUSFF4,  @nD1_CUSFF5, 'D',          '        ',  @cXB6_TPCF,
                                 @cXB6_ESTOQUE, @cXB6_IDENTB6, @iRecnoSB6)
         end

         fetch CUR_SD1DE into @cD1_FORNECE, @cD1_LOJA,   @cD1_COD,    @cD1_LOCAL,  @cD1_SEGUM, @cD1_DOC,     @cD1_SERIE,
                              @dD1_EMISSAO, @nD1_QUANT,  @cD1_TES,    @cF4_PODER3, @cD1_UM,    @nD1_QTSEGUM, @dD1_DTDIGIT,
                              @cD1_IDENTB6, @cD1_NUMSEQ, @nD1_CUSTO,  @nD1_CUSTO2, @nD1_CUSTO3, @nD1_CUSTO4, @nD1_CUSTO5,
                              @nD1_CUSFF1,  @nD1_CUSFF2, @nD1_CUSFF3, @nD1_CUSFF4, @nD1_CUSFF5, @cD1_TIPO,   @nD1_VUNIT,
                              @cF4_ESTOQUE,@iSD1_RECNO
         If @nContador > 1 begin
            Commit Tran
            select @nContador = 0
         End
      end

      close CUR_SD1DE
      deallocate CUR_SD1DE
      If @nContador > 0 begin
         Commit Tran
         select @iTranCount = 0
      End

      /* ---------------------------------------------------------------------------------------------
         Verifica no arquivo de pedidos liberados se existe algum item referente a
         devolucao poder de terceiros para atualizar a quantidade liberada - 11 - sc9
      ---------------------------------------------------------------------------------------------- */
      select @nContador = 0
      declare CUR_SC9 insensitive cursor for
      select SB6.R_E_C_N_O_, C9_QTDLIB, B6_QULIB, SC9.R_E_C_N_O_, SC9.C9_NFISCAL
      from SC9### SC9, SC6### SC6, SF4### SF4, SB6### SB6
      where C9_FILIAL   = @cFil_SC9
         and C9_NFISCAL  = ' '
         and C6_FILIAL   = @cFil_SC6
         and C6_NUM      = C9_PEDIDO
         and C6_ITEM     = C9_ITEM
         and C6_PRODUTO between @IN_MV_PAR01 and @IN_MV_PAR02
         and F4_FILIAL   = @cFil_SF4
         and F4_CODIGO   = C6_TES
         and F4_PODER3   = 'D'
         and B6_FILIAL   = @cFil_SB6
         and B6_IDENT    = C9_IDENTB6
         and B6_PRODUTO  = C6_PRODUTO
         and B6_PODER3   = 'R'
         and SC9.D_E_L_E_T_  = ' '
         and SC6.D_E_L_E_T_  = ' '
         and SF4.D_E_L_E_T_  = ' '
         and SB6.D_E_L_E_T_  = ' '
      for read only
      open CUR_SC9

      fetch CUR_SC9 into @iSB6_RECNO, @nC9_QTDLIB, @nB6_QULIB, @iSC9_RECNO, @cC9_NFISCAL

      while @@Fetch_status = 0 begin

         select @nB6_TQULIB = isnull( SUM (SC9.C9_QTDLIB), 0)
		   from SC9### SC9, SC6### SC6, SF4### SF4, SB6### SB6
         where SC9.C9_FILIAL = @cFil_SC9
            and SC9.C9_NFISCAL = ' '
            and SC6.C6_FILIAL = @cFil_SC6
            and SC6.C6_NUM = SC9.C9_PEDIDO
            and SC6.C6_ITEM = SC9.C9_ITEM
            and SC6.C6_PRODUTO between @IN_MV_PAR01 and @IN_MV_PAR02
            and SF4.F4_FILIAL = @cFil_SF4
            and SF4.F4_CODIGO = SC6.C6_TES
            and SF4.F4_PODER3 = 'D'
            and SB6.B6_FILIAL = @cFil_SB6
            and SB6.B6_IDENT = SC9.C9_IDENTB6
            and SB6.B6_PRODUTO = SC6.C6_PRODUTO
            and SB6.B6_PODER3 = 'R'
            and SC9.D_E_L_E_T_ = ' '
            and SC6.D_E_L_E_T_ = ' '
            and SF4.D_E_L_E_T_ = ' '
            and SB6.D_E_L_E_T_ = ' '
            and SB6.R_E_C_N_O_ = @iSB6_RECNO
         group by SB6.R_E_C_N_O_

         update SB6### set B6_QULIB = @nB6_TQULIB where R_E_C_N_O_ = @iSB6_RECNO

         select @nContador = @nContador + 1
         If @nContador = 1 begin
            Begin Tran
            Select @nContador = @nContador
         End

         fetch CUR_SC9 into @iSB6_RECNO, @nC9_QTDLIB, @nB6_QULIB, @iSC9_RECNO, @cC9_NFISCAL

         If @nContador > 1 begin
            Commit Tran
            select @nContador = 0
         End
      end

      close CUR_SC9
      deallocate CUR_SC9

      If @nContador > 0 begin
         commit Tran
         select @iTranCount = 0
      End

      /* ------------------------------------------------------------------------------------------------------------------
         Atualiza saldo físico e financeiro - 12
         ------------------------------------------------------------------------------------------------------------------ */
      select @nContador = 0
      declare CUR_SB6 insensitive cursor for
      select B6_LOCAL,   B6_PRODUTO, B6_IDENT, B6_TES, B6_PODER3, B6_QUANT, B6_ATEND, B6_ESTOQUE, SB6.R_E_C_N_O_, B6_DOC, B6_SERIE
      from SB6### SB6
      where B6_FILIAL    = @cFil_SB6
         and B6_PRODUTO between @IN_MV_PAR01 and @IN_MV_PAR02
         and SB6.D_E_L_E_T_  = ' '
   order by B6_FILIAL, B6_IDENT, B6_PRODUTO, B6_PODER3
   for read only
   open CUR_SB6

   fetch CUR_SB6 into @cB6_LOCAL, @cB6_PRODUTO, @cB6_IDENT, @cB6_TES, @cB6_PODER3, @nB6_QUANT,
                      @cB6_ATEND, @cB6_ESTOQUE, @iB6_RECNO, @cB6_DOC, @cB6_SERIE

   select @nB6_QULIB = 0
   select @nB6_QUANTAux = 0
   while @@Fetch_status = 0 begin

      select @nContador = @nContador + 1
      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End

      if @cB6_PODER3 = 'R' begin
         /* ------------------------------------------------------------------------------------------------------------
            MAT035 - CalcTerc ( matxatu ) Recupera saldo em poder de terceiros
            A var @nB6_QUANTAux - Nao é utilizada nesta procedure - só para compatibilizar com a funçao do padrao
            ------------------------------------------------------------------------------------------------------------ */
         select @cAux = ' '
         exec MAT035_## @IN_FILIALCOR, @cB6_PRODUTO, @cB6_IDENT, @cB6_TES, @cAux, @cAux, @cAux, @nB6_SALDO output,
                        @nB6_QULIB output, @nB6_QUANTAux output

         if @nB6_SALDO <= 0 select @cB6_ATEND = 'S'

            update SB6###
               set B6_SALDO = @nB6_SALDO, B6_QULIB = @nB6_QULIB, B6_ATEND = @cB6_ATEND
             where R_E_C_N_O_ = @iB6_RECNO

         end
         select @cF4_ESTOQUE = ''
         if @cB6_PODER3 = 'D' begin

            select @cB6_LOCAL = B6_LOCAL, @cF4_ESTOQUE = B6_ESTOQUE
            from SB6### (nolock)
            where B6_FILIAL   = @cFil_SB6
               and B6_IDENT    = @cB6_IDENT
               and B6_PRODUTO  = @cB6_PRODUTO
               and B6_PODER3   = 'R'
               and R_E_C_N_O_  = ( Select min(R_E_C_N_O_)
                                    from SB6### SB6 (nolock)
                                    where B6_FILIAL  = @cFil_SB6
                                    and B6_IDENT	  = @cB6_IDENT
                                    and B6_PRODUTO = @cB6_PRODUTO
                                    and B6_PODER3  = 'R'
                                    and D_E_L_E_T_ = ' ' )
               and D_E_L_E_T_ = ' '
         end
         /* --------------------------------------------------------------------------------
         Verifica se existe no SF4
            -------------------------------------------------------------------------------- */
         select @iRecnoSF4 = null
         select @nXB2_QTNP = 0
         select @nXB2_QNPT = 0
         select @nB2_QTER  = 0
         select @nXB2_QTER = 0
         select @iRecnoSB2 = 0
         select @nD1_QUANT = 0
         select @nD2_QUANT = 0

         If @cB6_TES < '501' Begin
            select distinct @nD1_QUANT = D1_QUANT from SD1###
            where D1_FILIAL = @cFil_SD1 and D1_IDENTB6 = @cB6_IDENT and D1_COD = @cB6_PRODUTO
                  and D1_DOC = @cB6_DOC and D1_SERIE = @cB6_SERIE
                  and D1_TES = @cB6_TES
                  and D1_QUANT = @nB6_QUANT and D_E_L_E_T_ = ' '
         end
         If @cB6_TES > '500' Begin
            select distinct @nD2_QUANT = D2_QUANT from SD2###
            where D2_FILIAL = @cFil_SD2 and D2_IDENTB6 = @cB6_IDENT and D2_COD = @cB6_PRODUTO
                  and D2_DOC = @cB6_DOC and D2_SERIE = @cB6_SERIE
                  and D2_TES = @cB6_TES
                  and D2_QUANT = @nB6_QUANT and D_E_L_E_T_ = ' '
         end

         select @iRecnoSF4 = Min(R_E_C_N_O_)
         from SF4###
         where F4_FILIAL = @cFil_SF4 and F4_CODIGO = @cB6_TES and D_E_L_E_T_ = ' '

         If @iRecnoSF4 is not null begin
            If @cF4_ESTOQUE = ' ' begin
               select @cF4_ESTOQUE = F4_ESTOQUE
               from SF4###
               where R_E_C_N_O_ = @iRecnoSF4
            end
            /* -------------------------------------------------------------------------------
               Cria ou obtem registro no SB2
               ------------------------------------------------------------------------------- */
            exec MAT025_## @IN_FILIALCOR, @cB6_PRODUTO, @cB6_LOCAL, @iRecnoSB2 output

            select @nB2_QTNP = B2_QTNP, @nB2_QNPT = B2_QNPT, @nB2_QTER = B2_QTER
            from SB2###
            where R_E_C_N_O_ = @iRecnoSB2

            If @nB2_QTNP is not Null begin
               select @nXB2_QTNP = @nB2_QTNP
               select @nXB2_QNPT = @nB2_QNPT
               select @nXB2_QTER = @nB2_QTER
            End

            /* -------------------------------------------------------------------------------
               SAÍDAS - TES > 500
               ------------------------------------------------------------------------------- */
            if @cB6_TES > '500' begin
               if @cF4_ESTOQUE = 'S' OR @cB6_ESTOQUE = 'S' begin
                  If @cB6_PODER3 = 'D'      select @nXB2_QTNP = @nB2_QTNP - @nB6_QUANT
                  else if @cB6_PODER3 = 'R' select @nXB2_QNPT = @nB2_QNPT + @nB6_QUANT
               end
               else begin
                  If @cB6_PODER3 = 'D'      select @nXB2_QTER = @nB2_QTER - @nD2_QUANT
                  else if @cB6_PODER3 = 'R' select @nXB2_QTER = @nB2_QTER + @nD2_QUANT
               end
            end
            /* -------------------------------------------------------------------------------
               ENTRADAS- < 500 TES
               ------------------------------------------------------------------------------- */
            else begin
               if @cF4_ESTOQUE = 'S' OR @cB6_ESTOQUE = 'S' begin
                  If @cB6_PODER3 = 'D'      select @nXB2_QNPT = @nB2_QNPT - @nB6_QUANT
                  else if @cB6_PODER3 = 'R' select @nXB2_QTNP = @nB2_QTNP + @nB6_QUANT
               end
               else begin
                  If @cB6_PODER3 = 'D'      select @nXB2_QTER = @nB2_QTER - @nD1_QUANT
                  else if @cB6_PODER3 = 'R' select @nXB2_QTER = @nB2_QTER + @nD1_QUANT
               end
            End
         /* -------------------------------------------------------------------------------
            Atualizacao do SB2
            ------------------------------------------------------------------------------- */
         UpDate SB2###
            Set B2_QTNP = @nXB2_QTNP, B2_QNPT = @nXB2_QNPT,  B2_QTER = @nXB2_QTER
            Where R_E_C_N_O_ = @iRecnoSB2

      end

      fetch CUR_SB6 into @cB6_LOCAL, @cB6_PRODUTO, @cB6_IDENT, @cB6_TES, @cB6_PODER3, @nB6_QUANT, @cB6_ATEND, @cB6_ESTOQUE, @iB6_RECNO, @cB6_DOC, @cB6_SERIE

      If @nContador > 1 begin
         Commit Tran
         select @nContador = 0
      End
   end

   close CUR_SB6
   deallocate CUR_SB6
   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End

   select @OUT_RESULTADO = '1'

end
