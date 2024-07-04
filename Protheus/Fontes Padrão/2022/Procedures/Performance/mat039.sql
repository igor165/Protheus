create procedure MAT039_##
(
 @IN_FILIALCOR  char('B1_FILIAL'),
 @IN_MES        char(02),
 @OUT_RESULTADO char(01) output
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Descricao   -  <d> Zera o arquivo de consumos </d>
    Assinatura  -  <a> 003 </a>
    Entrada     -  <ri>
                   @IN_FILIALCOR  - Filial corrente
                   @IN_MES        - Mes que deve ser zerado </ri>

    Saida       -  <ro> @OUT_RESULTADO - Retorno de processamento </ro>

    Responsavel -  <r> Ricardo Gonçalves </r>
    Observações -  <o> Função anexa a rotina de fechamento mensal de saldos em estoque (mata280.prx) </o>
    Data        -  <dt> 05.10.2001 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT039 - Zera o arquivo de consumos

--------------------------------------------------------------------------------------------------------------------- */

declare @cFil_SB3       Char('B3_FILIAL')
declare @nMaxRecnoSB3   integer
declare @nRec           integer
declare @nRecAnt        integer
declare @cAux           Varchar(3)
declare @nContador      integer
declare @iTranCount     integer --Var.de ajuste para SQLServer e Sybase.
                               -- Será trocada por Commit no CFGX051 após passar pelo Parse

begin

   select @OUT_RESULTADO = '0'
   /* ------------------------------------------------------------------------------------------------------------------
       Recupera filiais
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SB3'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB3 OutPut

   select @nMaxRecnoSB3 = MAX(R_E_C_N_O_)
     from SB3###
    where B3_FILIAL  = @cFil_SB3

   if @nMaxRecnoSB3 is null select @nMaxRecnoSB3 = 0

   select @nRec = 0
   select @nContador = 0

   while @nRec <= @nMaxRecnoSB3 begin
      select @nRecAnt = @nRec
      select @nRec = @nRec + 1024
      select @nContador = @nContador + 1

      If @nContador = 1 begin
         begin tran
         select @nContador = @nContador
      End

      if (@IN_MES = '01')
         update SB3###
            set B3_Q01 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '02')
         update SB3###
            set B3_Q02 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '03')
         update SB3###
            set B3_Q03 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '04')
         update SB3###
            set B3_Q04 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '05')
         update SB3###
            set B3_Q05 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '06')
         update SB3###
            set B3_Q06 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '07')
         update SB3###
            set B3_Q07 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '08')
         update SB3###
            set B3_Q08 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '09')
         update SB3###
            set B3_Q09 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '10')
         update SB3###
            set B3_Q10 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '11')
         update SB3###
            set B3_Q11 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      if (@IN_MES = '12')
         update SB3###
            set B3_Q12 = 0
          where R_E_C_N_O_ > @nRecAnt and R_E_C_N_O_ <= @nRec and B3_FILIAL = @cFil_SB3 and D_E_L_E_T_ = ' '

      If @nContador > 1023 begin
         Commit Tran
         Select @nContador = 0
      End
   end

   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End
   select @OUT_RESULTADO = '1'

end
