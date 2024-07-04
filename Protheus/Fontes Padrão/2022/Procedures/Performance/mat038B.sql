Create Procedure MAT038B_##
(
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_MV_ULMES     char(08),
 @OUT_RESULTADO   char(01) OutPut
)
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> mata280 </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Transferencia de Saldos nas Ordens de Produção </d>
    Entrada     -  <ri> @IN_FILIALCOR
                        @IN_MV_ULMES
                        @OUT_RESULTADO </ri>

    Saida       -  <ro> @OUT_RESULTADO - Houve sucesso ou não </ro>

    Responsavel :  <r> reynaldo </r>
    Data        :  <dt> 30.10.2020 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT038B - Transferencia de Saldos nas Ordens de Produção
      1.XFILIAL - Codigo da Filial do sistema
      1.MA280INC2CP - Ponto de Entrada.

--------------------------------------------------------------------------------------------------------------------- */

Declare @cFil_SC2       Char('C2_FILIAL')

/* ---------------------------------------------------------------------------------------------------------------------
   Variáveis para cursor
--------------------------------------------------------------------------------------------------------------------- */
declare @vRecno         int

declare @nC2_VFIM1      decimal( 'C2_VFIM1' )
declare @nC2_VFIM2      decimal( 'C2_VFIM2' )
declare @nC2_VFIM3      decimal( 'C2_VFIM3' )
declare @nC2_VFIM4      decimal( 'C2_VFIM4' )
declare @nC2_VFIM5      decimal( 'C2_VFIM5' )
declare @nC2_APRFIM1    decimal( 'C2_APRFIM1' )
declare @nC2_APRFIM2    decimal( 'C2_APRFIM2' )
declare @nC2_APRFIM3    decimal( 'C2_APRFIM3' )
declare @nC2_APRFIM4    decimal( 'C2_APRFIM4' )
declare @nC2_APRFIM5    decimal( 'C2_APRFIM5' )

declare @nC2_VFIMRP1    decimal( 'C2_VFIM1' )
declare @nC2_VFIMRP2    decimal( 'C2_VFIM2' )
declare @nC2_VFIMRP3    decimal( 'C2_VFIM3' )
declare @nC2_VFIMRP4    decimal( 'C2_VFIM4' )
declare @nC2_VFIMRP5    decimal( 'C2_VFIM5' )
declare @nC2_APRFRP1    decimal( 'C2_APRFIM1' )
declare @nC2_APRFRP2    decimal( 'C2_APRFIM2' )
declare @nC2_APRFRP3    decimal( 'C2_APRFIM3' )
declare @nC2_APRFRP4    decimal( 'C2_APRFIM4' )
declare @nC2_APRFRP5    decimal( 'C2_APRFIM5' )

declare @nC2_VFIMFF1    decimal( 'C2_VFIMFF1' )
declare @nC2_VFIMFF2    decimal( 'C2_VFIMFF2' )
declare @nC2_VFIMFF3    decimal( 'C2_VFIMFF3' )
declare @nC2_VFIMFF4    decimal( 'C2_VFIMFF4' )
declare @nC2_VFIMFF5    decimal( 'C2_VFIMFF5' )

declare @cAux           Varchar(3)
declare @nAux           integer
declare @nContador      integer
declare @iTranCount     integer --Var.de ajuste para SQLServer e Sybase. Será trocada por Commit no CFGX051 após passar pelo Parse
declare @iPos           integer

begin

   select @OUT_RESULTADO = '0'

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */

   /* ------------------------------------------------------------------------------------------------------------------
      Recupera filiais das tabelas
   ------------------------------------------------------------------------------------------------------------------ */
   select @cAux = 'SC2'
   exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SC2 OutPut

   select @nContador = 0

   /* ------------------------------------------------------------------------------------------------------------------
        Transfere os saldos das OP's
   ------------------------------------------------------------------------------------------------------------------ */
   select @nContador = 0

   declare CUR_M280SC2 insensitive cursor for
      select C2_VFIM1,   C2_VFIM2,   C2_VFIM3,   C2_VFIM4,   C2_VFIM5, C2_APRFIM1,
             C2_APRFIM2, C2_APRFIM3, C2_APRFIM4, C2_APRFIM5, R_E_C_N_O_
		     ##FIELDP25( 'SC2.C2_VFIMRP1;SC2.C2_VFIMRP2;SC2.C2_VFIMRP3;SC2.C2_VFIMRP4;SC2.C2_VFIMRP5' )
			  ,C2_VFIMRP1 , C2_VFIMRP2 , C2_VFIMRP3, C2_VFIMRP4, C2_VFIMRP5
		     ##ENDFIELDP25
		     ##FIELDP26( 'SC2.C2_APRFRP1;SC2.C2_APRFRP2;SC2.C2_APRFRP3;SC2.C2_APRFRP4;SC2.C2_APRFRP5' )
			  ,C2_APRFRP1 , C2_APRFRP2 , C2_APRFRP3, C2_APRFRP4, C2_APRFRP5
		     ##ENDFIELDP26
		     ##FIELDP33( 'SC2.C2_VFIMFF1;SC2.C2_VFIMFF2;SC2.C2_VFIMFF3;SC2.C2_VFIMFF4;SC2.C2_VFIMFF5' )
			  ,C2_VFIMFF1 , C2_VFIMFF2 , C2_VFIMFF3, C2_VFIMFF4, C2_VFIMFF5
		     ##ENDFIELDP33
        from SC2### (nolock)
       where C2_FILIAL  = @cFil_SC2
         and (C2_DATRF  > @IN_MV_ULMES or C2_DATRF = '        ')
         and D_E_L_E_T_ = ' '
   for read only

   open CUR_M280SC2

   fetch CUR_M280SC2 into @nC2_VFIM1,   @nC2_VFIM2,   @nC2_VFIM3,   @nC2_VFIM4,   @nC2_VFIM5, @nC2_APRFIM1,
                          @nC2_APRFIM2, @nC2_APRFIM3, @nC2_APRFIM4, @nC2_APRFIM5, @vRecno
						  ##FIELDP27( 'SC2.C2_VFIMRP1;SC2.C2_VFIMRP2;SC2.C2_VFIMRP3;SC2.C2_VFIMRP4;SC2.C2_VFIMRP5' )
						   ,@nC2_VFIMRP1 , @nC2_VFIMRP2 , @nC2_VFIMRP3, @nC2_VFIMRP4, @nC2_VFIMRP5
						  ##ENDFIELDP27
						  ##FIELDP28( 'SC2.C2_APRFRP1;SC2.C2_APRFRP2;SC2.C2_APRFRP3;SC2.C2_APRFRP4;SC2.C2_APRFRP5' )
						   ,@nC2_APRFRP1 , @nC2_APRFRP2 , @nC2_APRFRP3, @nC2_APRFRP4, @nC2_APRFRP5
						  ##ENDFIELDP28
   		           ##FIELDP34( 'SC2.C2_VFIMFF1;SC2.C2_VFIMFF2;SC2.C2_VFIMFF3;SC2.C2_VFIMFF4;SC2.C2_VFIMFF5' )
			            ,@nC2_VFIMFF1 , @nC2_VFIMFF2 , @nC2_VFIMFF3, @nC2_VFIMFF4, @nC2_VFIMFF5
		              ##ENDFIELDP34

   while (@@fetch_status = 0) begin


      select @nContador = @nContador + 1
      If @nContador = 1 begin
         Begin Tran
         select @nContador = @nContador
      End

      update SC2###
         set C2_VINI1   = @nC2_VFIM1,   C2_VINI2   = @nC2_VFIM2,   C2_VINI3   = @nC2_VFIM3,   C2_VINI4   = @nC2_VFIM4,
             C2_VINI5   = @nC2_VFIM5,   C2_APRINI1 = @nC2_APRFIM1, C2_APRINI2 = @nC2_APRFIM2, C2_APRINI3 = @nC2_APRFIM3,
             C2_APRINI4 = @nC2_APRFIM4, C2_APRINI5 = @nC2_APRFIM5
		    ##FIELDP29( 'SC2.C2_VINIRP1;SC2.C2_VINIRP2;SC2.C2_VINIRP3;SC2.C2_VINIRP4;SC2.C2_VINIRP5' )
            ,C2_VINIRP1 = @nC2_VFIMRP1, C2_VINIRP2 = @nC2_VFIMRP2, C2_VINIRP3 = @nC2_VFIMRP3, C2_VINIRP4 = @nC2_VFIMRP4, C2_VINIRP5 = @nC2_VFIMRP5
		    ##ENDFIELDP29
		    ##FIELDP30( 'SC2.C2_APRIRP1;SC2.C2_APRIRP2;SC2.C2_APRIRP3;SC2.C2_APRIRP4;SC2.C2_APRIRP5' )
			,C2_APRIRP1 = @nC2_APRFRP1, C2_APRIRP2 = @nC2_APRFRP2 , C2_APRIRP3 = @nC2_APRFRP3, C2_APRIRP4 = @nC2_APRFRP4, C2_APRIRP5 = @nC2_APRFRP5
		    ##ENDFIELDP30
   		##FIELDP35( 'SC2.C2_VINIFF1;SC2.C2_VINIFF2;SC2.C2_VINIFF3;SC2.C2_VINIFF4;SC2.C2_VINIFF5' )
			,C2_VINIFF1 = @nC2_VFIMFF1, C2_VINIFF2 = @nC2_VFIMFF2 , C2_VINIFF3 = @nC2_VFIMFF3, C2_VINIFF4 = @nC2_VFIMFF4, C2_VINIFF5 = @nC2_VFIMFF5
         ##ENDFIELDP35
       where R_E_C_N_O_ = @vRecno

       /* ---------------------------------------------------------------------------------------------------------------
          Gravar os Valores finais no SC2 com o CUSTO EM PARTES.
       --------------------------------------------------------------------------------------------------------------- */
      EXEC MA280INC2CP_## @vRecno

      fetch CUR_M280SC2 into @nC2_VFIM1,   @nC2_VFIM2,   @nC2_VFIM3,   @nC2_VFIM4,   @nC2_VFIM5, @nC2_APRFIM1,
                             @nC2_APRFIM2, @nC2_APRFIM3, @nC2_APRFIM4, @nC2_APRFIM5, @vRecno
						     ##FIELDP31( 'SC2.C2_VFIMRP1;SC2.C2_VFIMRP2;SC2.C2_VFIMRP3;SC2.C2_VFIMRP4;SC2.C2_VFIMRP5' )
						     ,@nC2_VFIMRP1 , @nC2_VFIMRP2 , @nC2_VFIMRP3, @nC2_VFIMRP4, @nC2_VFIMRP5
						     ##ENDFIELDP31
						     ##FIELDP32( 'SC2.C2_APRFRP1;SC2.C2_APRFRP2;SC2.C2_APRFRP3;SC2.C2_APRFRP4;SC2.C2_APRFRP5' )
						     ,@nC2_APRFRP1 , @nC2_APRFRP2 , @nC2_APRFRP3, @nC2_APRFRP4, @nC2_APRFRP5
						     ##ENDFIELDP32
                       ##FIELDP36( 'SC2.C2_VFIMFF1;SC2.C2_VFIMFF2;SC2.C2_VFIMFF3;SC2.C2_VFIMFF4;SC2.C2_VFIMFF5' )
			              ,@nC2_VFIMFF1 , @nC2_VFIMFF2 , @nC2_VFIMFF3, @nC2_VFIMFF4, @nC2_VFIMFF5
                       ##ENDFIELDP36
      If @nContador > 1023 begin
         Commit Tran
         select @nContador = 0
      End
   end -- end while

   close CUR_M280SC2
   deallocate CUR_M280SC2

   If @nContador > 0 begin
      Commit Tran
      select @iTranCount = 0
   End
   select @OUT_RESULTADO = '1'

end
