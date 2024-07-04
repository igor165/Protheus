Create procedure MAT013_##

 (
   @IN_FILIALCOR   char('B1_FILIAL'),
   @IN_MV_RASTRO   char(01),
   @IN_MV_LOCALIZ  char(01),
   @IN_DINICIO     char(08),
   @IN_MV_PAR1     char(08),
   @IN_MV_WMSNEW   char(01),
   @IN_MV_ARQPROD  char(03),
   @OUT_RESULTADO  Char(01) OutPut
 )
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> MA330DELD3 </s>
    Assinatura  -  <a> 007 </a>
    Descricao   -  <d> Apaga movimentos de estorno no SD3 </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_MV_RASTRO    - Conteudo de GetMV("MV_RASTRO")
                   @IN_MV_LOCALIZ   - Conteudo de GetMV("MV_LOCALIZ")
                   </ri>
    Responsavel :  <r> Emerson Tobar </r>
    Data        :  <dt> 20/06/00 </dt>
--------------------------------------------------------------------------------------------------------------------- */

declare @cFil_SD3    char('D3_FILIAL')
declare @cFil_SD5    char('D5_FILIAL')
declare @cFil_SDB    char('DB_FILIAL')
declare @cRastro     char(01)
declare @cLocaliza   char(01)
declare @cD3_COD     char('D3_COD')
declare @cD3_NUMSEQ  char('D3_NUMSEQ')
declare @cD3_LOCAL   char('D3_LOCAL')
declare @cD3_LOTECTL char('D3_LOTECTL')
declare @cD3_NUMLOTE char('D3_NUMLOTE')
declare @cD3_DOC     char('D3_DOC')
declare @iD3_Recno   int
declare @cAux        Varchar(3)
declare @nContador   integer
declare @dDINICIO    char(08)
declare @cMV_PAR1    char(08)
declare @iTranCount  integer --Var.de ajuste para SQLServer e Sybase.
                             -- Será trocada por Commit no CFGX051 após passar pelo Parse

begin

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @dDINICIO = @IN_DINICIO
   select @cMV_PAR1 = @IN_MV_PAR1

   select @cAux = 'SD3'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD3 OutPut
   select @cAux = 'SD5'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD5 OutPut
   select @cAux = 'SDB'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SDB OutPut

   select @nContador = 0
   declare Cur_D3_ESTORNO insensitive cursor for
      select R_E_C_N_O_, D3_COD, D3_NUMSEQ, D3_LOCAL, D3_LOTECTL, D3_NUMLOTE, D3_DOC
        from SD3### SD3
       where D3_FILIAL   = @cFil_SD3
         and D3_EMISSAO >= @dDINICIO
         and D3_EMISSAO <= @cMV_PAR1
         and D3_ESTORNO  = 'S'
         and SD3.D_E_L_E_T_ = ' '
      ##IF_001({|| IIF(FindFunction('T_TDCEA010'), .T., .F. )})
		 and D3_NUMSEQ =
         (Select SD3DCL.D3_NUMSEQ
          from SD3### SD3DCL
          where SD3DCL.D3_FILIAL   = SD3.D3_FILIAL
            and SD3DCL.D3_COD      = SD3.D3_COD
            and SD3DCL.D3_LOCAL    = SD3.D3_LOCAL
            and SD3DCL.D3_EMISSAO  = SD3.D3_EMISSAO
            and SD3DCL.D3_NUMSEQ   = SD3.D3_NUMSEQ
            and SD3DCL.R_E_C_N_O_ <> SD3.R_E_C_N_O_
            and SD3DCL.D3_ESTORNO  = 'S'
            and SD3DCL.D3_TM      <> SD3.D3_TM
            and SD3DCL.D_E_L_E_T_ = ' ')
      ##ENDIF_001


   open Cur_D3_ESTORNO
   fetch Cur_D3_ESTORNO into @iD3_Recno, @cD3_COD, @cD3_NUMSEQ, @cD3_LOCAL, @cD3_LOTECTL, @cD3_NUMLOTE, @cD3_DOC
   while ( @@Fetch_Status = 0 ) begin

      select @nContador = @nContador + 1
      /* -------------------------------------------------------------------------
         Verifica se a rastreabilidade esta em uso
         ------------------------------------------------------------------------- */
      select @cRastro = ' '
      select @cAux = ' '
      exec MAT011_## @IN_MV_RASTRO, @cD3_COD, @cAux, @IN_FILIALCOR, @cRastro OutPut

      If @nContador = 1 begin
         select @nContador = @nContador
         Begin Tran
      End

      if ( @cRastro = '1' ) begin
         /* -----------------------------------------------------------------------
           Verifica se a rastreabilidade esta em uso para sublote
         ----------------------------------------------------------------------- */
         select @cAux = 'S'
         exec MAT011_## @IN_MV_RASTRO, @cD3_COD, @cAux, @IN_FILIALCOR, @cRastro OutPut
        /* -----------------------------------------------------------------------
           Executa a exclusao das linhas no SD5
         ----------------------------------------------------------------------- */
         if ( @cRastro = '1' ) begin
            delete
              from SD5###
             where D5_FILIAL  = @cFil_SD5
               and D5_NUMSEQ  = @cD3_NUMSEQ and D5_PRODUTO = @cD3_COD
               and D5_LOCAL   = @cD3_LOCAL  and D5_LOTECTL = @cD3_LOTECTL
               and D5_ESTORNO = 'S'         and D5_NUMLOTE = @cD3_NUMLOTE
               and D_E_L_E_T_ = ' '

         end else begin
            delete
              from SD5###
             where D5_FILIAL  = @cFil_SD5
               and D5_NUMSEQ  = @cD3_NUMSEQ and D5_PRODUTO = @cD3_COD
               and D5_LOCAL   = @cD3_LOCAL  and D5_LOTECTL = @cD3_LOTECTL
               and D5_ESTORNO = 'S'         and D_E_L_E_T_ = ' '

         end
      end
      /* -------------------------------------------------------------------------
         Verifica se a localizacao esta em uso
      ------------------------------------------------------------------------- */
      if ( @IN_MV_LOCALIZ = 'S' ) begin
         exec MAT012_## @cD3_COD, @IN_FILIALCOR, @IN_MV_WMSNEW, @IN_MV_ARQPROD, @cLocaliza OutPut
         if @cLocaliza = '1' begin
            /* -----------------------------------------------------------------------
               Executa a exclusao das linhas no SBD
            ----------------------------------------------------------------------- */
            delete
              from SDB###
             where DB_FILIAL  = @cFil_SDB  and DB_PRODUTO = @cD3_COD
               and DB_LOCAL   = @cD3_LOCAL and DB_NUMSEQ  = @cD3_NUMSEQ
               and DB_DOC     = @cD3_DOC   and DB_ESTORNO = 'S'
               and D_E_L_E_T_ = ' '
         end
      end
      delete
        from SD3###
       where R_E_C_N_O_ = @iD3_Recno
      fetch Cur_D3_ESTORNO into @iD3_Recno, @cD3_COD, @cD3_NUMSEQ, @cD3_LOCAL, @cD3_LOTECTL, @cD3_NUMLOTE, @cD3_DOC

      If @nContador > 1023 begin
         Commit Tran
         select @nContador = 0
      End

   end
	close      Cur_D3_ESTORNO
	deallocate Cur_D3_ESTORNO

   If @nContador > 0 begin
      select @iTranCount = 0
      Commit Tran
   End
end
select @OUT_RESULTADO = '1'
