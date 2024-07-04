create procedure MAT035_##
(
 @IN_FILIALCOR  char('B1_FILIAL'),
 @IN_PRODUTO    char( 'B6_PRODUTO' ),
 @IN_IDENT      char( 'B6_IDENT' ),
 @IN_TES        char( 'F4_CODIGO;B6_TES' ),
 @IN_TIPO       char( 'B6_TIPO' ),
 @IN_DTINI      char( 08 ),
 @IN_DTFIN      char( 08 ),
 @OUT_QTD       float output,
 @OUT_QULIB     float output,
 @OUT_SALDO     float output
)
as
/* -----------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Protheus P12 </v>
    ----------------------------------------------------------------------------------------------------------------
    Programa    :   <s> CalcTerc - MATXATU </s>
    ----------------------------------------------------------------------------------------------------------------
    Descricao   :   <d> Calcula saldo em poder de terceiros  </d>
    ----------------------------------------------------------------------------------------------------------------
    Assinatura  :   <a> 001 </a>
    ----------------------------------------------------------------------------------------------------------------
    Entrada     :  <ri> @IN_FILIALCOR  - Filial corrente 
                        @IN_PRODUTO    - Codigo do Produto
                        @IN_IDENT      - Codigo do identIficador do SB6
                        @IN_TES        - Codigo da Tes
                        @IN_TIPO       - Tipo da Nota
                        @IN_DTINI      - Data Inicial a ser Considerada na Composição do Saldo
                        @IN_DTFIN      - Data Final a ser Considerada na Composição do Saldo
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> @OUT_QTD       - Quantidade Poder Terceiro Liberada(ainda nao faturada)
                        @OUT_QULIB     - Quantidade Liberada
                        @OUT_SALDO     - Saldo de Poder Terceiro </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :   <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :   <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Ricardo Gonçalves </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 03/04/2002 </dt>
    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------------------------------------------
   Declaração de variáveis para cursor (Declare abaixo todas as variáveis utilidas no select do cursor)
--------------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------------
   Variaveis internas (Declare abaixo todas as variáveis utilizadas na procedure)
--------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_SB6        char('B6_FILIAL')
Declare @cFil_SF4        char('F4_FILIAL')
Declare @dDtIni          char(08)
Declare @dDtFin          char(08)
Declare @cB6_TPCF        char( 'B6_TPCF' )
Declare @cAux            Varchar(3)
Declare @nSaldo1         Decimal( 'B6_QUANT' )
Declare @nSaldo2         Decimal( 'B6_QULIB' )
Declare @nSaldo3         Decimal( 'B6_PRUNIT' )
Declare @nSaldo1Aux      Decimal( 'B6_QUANT' )
Declare @nB6_QUANT       Decimal( 'B6_QUANT' )
Declare @cF4_PODER3      Char( 'F4_PODER3')
Declare @nB6_QULIB       Decimal( 'B6_QULIB' )
Declare @nB6_PRUNIT      Decimal( 'B6_PRUNIT' )
Declare @cB6_IDENTB6     Char( 'B6_IDENTB6' )
Declare @cB6_TES         Char( 'B6_TES' )

begin
   
   select @OUT_SALDO = 0
   select @OUT_QTD   = 0
   select @OUT_QULIB = 0
   select @dDtIni    = @IN_DTINI
   select @dDtFin    = @IN_DTFIN

   if @dDtIni = ' ' select @dDtIni = '17000102'
   if @dDtFin = ' ' select @dDtFin = '99999999' 

   if @IN_IDENT <> ' ' begin
      /* ----------------------------------------------------------------------------------------------------------------
          Recupera filiais
      ---------------------------------------------------------------------------------------------------------------- */
      select @cAux = 'SB6'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB6 OutPut   
      select @cAux = 'SF4'
      exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF4 OutPut   
      
      /* -------------------------------------------------------------------------------------------
         Totalizando Remessas/Devolucoes
      ---------------------------------------------------------------------------------------------- */
      declare CUR_B6 insensitive cursor for
      select B6_QUANT, B6_QULIB, B6_TES, B6_TPCF, B6_PRUNIT, B6_IDENTB6, SF4.F4_PODER3
        from SB6### SB6 (nolock), SF4### SF4 (nolock)
       where B6_FILIAL        = @cFil_SB6
         and B6_IDENT         = @IN_IDENT
         and B6_PRODUTO       = @IN_PRODUTO
         and B6_DTDIGIT between @dDtIni and @dDtFin
         and F4_FILIAL        = @cFil_SF4
         and F4_CODIGO        = B6_TES
         and SB6.D_E_L_E_T_   = ' '
         and SF4.D_E_L_E_T_   = ' '
      for read only
      open CUR_B6
      
      fetch CUR_B6 into @nB6_QUANT, @nB6_QULIB, @cB6_TES, @cB6_TPCF, @nB6_PRUNIT, @cB6_IDENTB6, @cF4_PODER3
      
      select @nSaldo1 = 0
      select @nSaldo2 = 0
      select @nSaldo3 = 0
      select @nSaldo1Aux = 0
      
      while @@Fetch_status = 0 begin
         
         if @IN_TES <= '500' begin
            if ( @IN_TIPO = 'B' and @cB6_TPCF <> 'C' ) Or ( @IN_TIPO = 'N' and @cB6_TPCF <> 'F') begin
               fetch CUR_B6 into @nB6_QUANT, @nB6_QULIB, @cB6_TES, @cB6_TPCF, @nB6_PRUNIT, @cB6_IDENTB6, @cF4_PODER3
               continue
            end
         end
         else begin
            If ( @IN_TIPO = 'B' and @cB6_TPCF <> 'F') or ( @IN_TIPO = 'N' and @cB6_TPCF <> 'C' ) begin
               fetch CUR_B6 into @nB6_QUANT, @nB6_QULIB, @cB6_TES, @cB6_TPCF, @nB6_PRUNIT, @cB6_IDENTB6, @cF4_PODER3
               continue
            end
         end
         
         /* -------------------------------------------------------------
            Remessa
            ------------------------------------------------------------- */
         If @cF4_PODER3 = 'R' begin
            select @nSaldo1 = @nSaldo1 + @nB6_QUANT
            select @nSaldo2 = @nSaldo2 + @nB6_QULIB
            /* ---------------------------------------------------------------------------------
               Ajusta a varauxiliar nSaldo1Aux
               --------------------------------------------------------------------------------- */
            If @nSaldo1 = 0 select @nSaldo1Aux = 1
            else select @nSaldo1Aux = @nSaldo1
            select @nSaldo3 = @nSaldo3 + ( @nB6_PRUNIT * @nSaldo1Aux )
         end
            
         /* -------------------------------------------------------------
            D evolucao
         ------------------------------------------------------------- */
         else if @cF4_PODER3 = 'D'  select @nSaldo1 = @nSaldo1 - @nB6_QUANT
         
         fetch CUR_B6 into @nB6_QUANT, @nB6_QULIB, @cB6_TES, @cB6_TPCF, @nB6_PRUNIT, @cB6_IDENTB6, @cF4_PODER3
         
      end
      close CUR_B6
      deallocate CUR_B6
   end
   
   select @OUT_QTD   = @nSaldo1
   select @OUT_QULIB = @nSaldo2
   select @OUT_SALDO = @nSaldo3
   
end
