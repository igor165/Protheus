Create procedure MAT058_##
(
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_DATA         char(08),
 @IN_CODIGO       char('B1_COD'),
 @IN_LOCAL        char('B1_LOCPAD'),
 @IN_MV_ULMES     char(08),
 @IN_300SALNEG    char(01),
 @IN_B2_QFIM      float,
 @IN_CONSULTA     char(01),
 @IN_FILSEQ       integer,
 @IN_MV_WMSNEW    char(01),
 @IN_MV_ARQPROD   char(03),
 @OUT_SOMASBF     float OutPut
)

##FIELDP01( 'D14.D14_FILIAL' )
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> mata280.prx -> BKAtuComB2 </s>
    Assinatura  -  <a> 014 </a>
    Descricao   -  <d> Efetua a gravação no arquivo D15 - Saldos Localização. </d>
    Entrada     -  <ri> @IN_FILIALCOR  - Filial corrente
                   @IN_DATA       - Data de fechamento
                   @IN_CODIGO     - Codigo do produto
                   @IN_LOCAL      - Localizacao </ri>

    Saida       -  <ro> @OUT_SOMASBF - Soma das Quantidades do SBF </ro>

    Responsavel :  <r> Bruno Schmidt / Alexsander Correia </r>
    Data        :  <dt> 04.10.2001 </dt>
--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_D11  Char('D11_FILIAL')
Declare @cFil_D13  Char('D13_FILIAL')
Declare @cFil_D15  Char('D15_FILIAL')


Declare @lLocaliz  Char(01)

/* ---------------------------------------------------------------------------------------------------------------------
   Variáveis para cursor
--------------------------------------------------------------------------------------------------------------------- */
declare @cEndereco char('D13_ENDER')
declare @cProduto  char('D13_PRODUT')
declare @cLoteCtl  char('D13_LOTECT')
declare @cNumLote  char('D13_NUMLOT')
declare @cNumSerie char('D13_NUMSER')
declare @cIdUnit   char('D13_IDUNIT')
declare @cTm       char('D13_TM')

declare @nSaldo    float
declare @nSaldo2   float

declare @nRecno    int
declare @cAux      Varchar(3)
declare @nDifSB2   float
declare @nQtMult   integer
declare @nCount    integer

begin

   select @OUT_SOMASBF = 0
   select @nDifSB2     = 0

   /* ------------------------------------------------------------------------------------------------------------------
       Verifica se o produto usa controle de lote
   ------------------------------------------------------------------------------------------------------------------ */
   exec MAT012_## @IN_CODIGO, @IN_FILIALCOR, @IN_MV_WMSNEW, @IN_MV_ARQPROD, @lLocaliz output

   if @lLocaliz = '1' begin

      /* ---------------------------------------------------------------------------------------------------------------
          Recupera filiais das tabelas
      --------------------------------------------------------------------------------------------------------------- */
      select @cAux = 'D13'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_D13 OutPut
      select @cAux = 'D15'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_D15 OutPut
      select @cAux = 'D11'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_D11 OutPut
      /* ---------------------------------------------------------------------------------------------------------------
         Declara o cursor para formar o saldo do fechamento D15
         Busca o saldo inicial D15 do ultimo fechamento
         Calcula as movimentações do kardex por endereço do período
      --------------------------------------------------------------------------------------------------------------- */
      declare CUR_D15 insensitive cursor for
       select D15_ENDER,
              D15_PRODUT,
              D15_LOTECT,
              D15_NUMLOT,
              D15_NUMSER,
              D15_IDUNIT,
              '000' TM,
              D15_QINI,
              D15_QISEGU
         from D15### D15
        where D15_FILIAL = @cFil_D15
          and D15_LOCAL  = @IN_LOCAL
          and D15_PRDORI = @IN_CODIGO
          and D15_DATA   = @IN_MV_ULMES
          and D15_QINI  <> 0
          and D15.D_E_L_E_T_ = ' '
        union all
       select D13_ENDER,
              D13_PRODUT,
              D13_LOTECT,
              D13_NUMLOT,
              D13_NUMSER,
              D13_IDUNIT,
              D13_TM,
              sum(D13_QTDEST) SALDO,
              sum(D13_QTDES2) SALDO2
         from D13### D13
        where D13_FILIAL  = @cFil_D13
          and D13_LOCAL   = @IN_LOCAL
          and D13_PRDORI  = @IN_CODIGO
          and D13_DTESTO  > @IN_MV_ULMES
          and D13_DTESTO <= @IN_DATA
		  ##FIELDP02( 'D13.D13_USACAL' )
			and D13_USACAL <> '2'
		  ##ENDFIELDP02
          and D13.D_E_L_E_T_ = ' '
        group by D13_ENDER,
                 D13_PRODUT,
                 D13_LOTECT,
                 D13_NUMLOT,
                 D13_NUMSER,
                 D13_IDUNIT,
                 D13_TM
       order by 1,2,3,4,5,6,7
      for read only

      open CUR_D15
      fetch CUR_D15 into @cEndereco, @cProduto, @cLoteCtl, @cNumLote, @cNumSerie, @cIdUnit, @cTm, @nSaldo, @nSaldo2

      while (@@Fetch_Status = 0) begin

         select @nRecno = null

         /* ---------------------------------------------------------------------------------------------------------
            Verifica se existe algum lançamento no D15 para decidir se faz inserção ou atualização
         --------------------------------------------------------------------------------------------------------- */
         if @IN_CONSULTA <> '1' Begin
            select @nRecno = R_E_C_N_O_
              from D15###
             where D15_FILIAL = @cFil_D15
               and D15_LOCAL  = @IN_LOCAL
               and D15_ENDER  = @cEndereco
               and D15_PRDORI = @IN_CODIGO
               and D15_PRODUT = @cProduto
               and D15_LOTECT = @cLoteCtl
               and D15_NUMLOT = @cNumLote
               and D15_NUMSER = @cNumSerie
               and D15_IDUNIT = @cIdUnit
               and D15_DATA   = @IN_DATA
               and D_E_L_E_T_ = ' '
         End

         if @cTm >= '500' Begin
            select @nSaldo  = (@nSaldo  * (-1))
            select @nSaldo2 = (@nSaldo2 * (-1))
         End

         if @nRecno is null begin
            /* ------------------------------------------------------------------------------------------------------
               Obtendo Recno
            ------------------------------------------------------------------------------------------------------ */
            select @nRecno = isnull(max( R_E_C_N_O_ ),0) from D15###
            select @nRecno = @nRecno + 1

            if @IN_CONSULTA <> '1' Begin
               ##TRATARECNO @nRecno\
               insert into D15### (D15_FILIAL, D15_PRDORI, D15_PRODUT, D15_LOCAL, D15_LOTECT, D15_NUMLOT,
                                   D15_ENDER,  D15_NUMSER, D15_IDUNIT, D15_DATA,  D15_QINI,   D15_QISEGU, R_E_C_N_O_)
                           values (@cFil_D15,  @IN_CODIGO, @cProduto,  @IN_LOCAL, @cLoteCtl,  @cNumLote,
                                   @cEndereco, @cNumSerie, @cIdUnit,   @IN_DATA,  @nSaldo,    @nSaldo2,   @nRecno)
               ##FIMTRATARECNO
            End

         end else begin
            if @IN_CONSULTA <> '1' Begin
               update D15###
                  set D15_QINI   = D15_QINI   + @nSaldo,
                      D15_QISEGU = D15_QISEGU + @nSaldo2
                where R_E_C_N_O_ = @nRecno
            End

         end

         /* ------------------------------------------------------------------------------------------------------------
            Soma o saldo do produto filho na variável @OUT_SOMASBF de retorno
         ------------------------------------------------------------------------------------------------------------ */
         select @OUT_SOMASBF = @OUT_SOMASBF + @nSaldo
         /* ------------------------------------------------------------------------------------------------------------
            Busca o valor do múltiplo do produto, quando produto partes, do contrário atribui valor 1
         ------------------------------------------------------------------------------------------------------------ */
         select @nQtMult = D11_QTMULT
           from D11###
          where D11_FILIAL = @cFil_D11
            and D11_PRODUT = @IN_CODIGO
            and D11_PRDORI = @IN_CODIGO
            and D11_PRDCMP = @cProduto
            and D_E_L_E_T_ = ' '

         if @nQtMult is null Begin
            select @nQtMult = 1
         End
         /* ------------------------------------------------------------------------------------------------------------
            Soma os valores de D15 para verificar se existe divergencia, dividindo pelo multiplo
         ------------------------------------------------------------------------------------------------------------ */
         select @nDifSB2 = @nDifSB2 + (@nSaldo / @nQtMult)
         /* --------------------------------------------------------------------------------------------------------------
             Tratamento para o DB2 / MySQL
         -------------------------------------------------------------------------------------------------------------- */
         ##IF_001({|| AllTrim(Upper(TcGetDB())) == "DB2" .or. AllTrim(Upper(TcGetDB())) == "MYSQL" })
         SELECT @fim_CUR = 0
         ##ENDIF_001

         fetch CUR_D15 into @cEndereco, @cProduto, @cLoteCtl, @cNumLote, @cNumSerie, @cIdUnit, @cTm, @nSaldo, @nSaldo2
      end
      /* ---------------------------------------------------------------------------------------------------------------
         Conta a quantidade de produtos filhos que o pai possui, para dividir no cálculo da divergência
      --------------------------------------------------------------------------------------------------------------- */
      select @nCount = COUNT(*)
        from D11###
       where D11_FILIAL = @cFil_D11
         and D11_PRODUT = @IN_CODIGO
         and D11_PRDORI = @IN_CODIGO
         and D_E_L_E_T_ = ' '

      if (@nCount is null) OR (@nCount = 0) Begin
         select @nCount = 1
      End

      select @nDifSB2 = (@nDifSB2 / @nCount)
      /* ---------------------------------------------------------------------------------------------------------------
         Alimenta arquivo temporario referente as diferencas entre SB2 e D15
      --------------------------------------------------------------------------------------------------------------- */
      if @IN_CONSULTA <> '1' and Round(@nDifSB2,6) <> Round(@IN_B2_QFIM,6) begin
         select @cAux = 'D14'
         insert into TRC### (TRC_FILIAL, TRC_COD, TRC_LOCAL, TRC_ALIAS, TRC_QFIM, TRC_DIVERG)
                     values (@IN_FILIALCOR, @IN_CODIGO, @IN_LOCAL, @cAux, @IN_B2_QFIM, @nDifSB2)
      End

      close CUR_D15
      deallocate CUR_D15

   end

end
##ENDFIELDP01