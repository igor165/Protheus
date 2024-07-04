CREATE PROCEDURE MAT016_##
(
   @IN_FILIALCOR   char('B2_FILIAL'),
   @OUT_RESULTADO Char(01) OUTPUT
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> A330PRCPR0 </s>
    Descricao   -  <d> Calcula qtd total da ordem de producao p/ proporcionalizar o custo de cada apontamento. </d>
    Assinatura  -  <a> 007 </a>
    Responsavel -  <r> Marco Norbiato </r>
    Data        -  <dt> 05/07/2000 </dt>
    Observacao  -  <o> Uso :  MATA330 </o>

    Estrutura de chamadas
    ========= == ========

    0.MAT016 - Calcula qtd total da ordem de producao p/ proporcionalizar o custo de cada apontamento.

--------------------------------------------------------------------------------------------------------------------- */
declare @cDATA     VarChar(08)
declare @cOP       VarChar('D3_OP')
declare @cCOD      VarChar('B1_COD')
declare @cFil      VarChar('B1_FILIAL')
declare @vQuant    float
declare @vPerda    float

begin
   declare TRX_Cursor insensitive cursor for
      select TRX_FILIAL, TRX_DATA, TRX_OP, TRX_COD, ISNULL( SUM( TRX_QUANT ), 0 ) QUANT, ISNULL( SUM( TRX_QPERDA ), 0 ) PERDA
      from TRX###
      where TRX_FILIAL = @IN_FILIALCOR
      group by TRX_FILIAL, TRX_DATA, TRX_OP, TRX_COD
   open  TRX_Cursor
   fetch TRX_Cursor
   into @cFil, @cDATA, @cOP, @cCOD, @vQuant, @vPerda
   while @@Fetch_Status = 0 Begin
      update TRX###
         set TRX_TOTAL   = @vQuant, TRX_TPERDA = @vPerda
       where TRX_FILIAL  = @cFil
         and TRX_DATA    = @cDATA
         and TRX_OP      = @cOP
         and TRX_COD     = @cCOD

      fetch TRX_Cursor
      into @cFil, @cDATA, @cOP, @cCOD, @vQuant, @vPerda
   end
   close      TRX_Cursor
   deallocate TRX_Cursor
   SELECT @OUT_RESULTADO = '1'
end
