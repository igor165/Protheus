Create Procedure MAT020_##
	(
		@IN_DATA       Char(08),
		@IN_MOEDA      Float,
		@OUT_TAXA      Float     Output
	)

as

/* ---------------------------------------------------------------------------------------------------------------------
	Versão      -  <v> Protheus 12 </v>
	Programa    -  <s> RecMoeda </s>
	Procedure   -  <d> Recupera taxa para moeda na data em questao </d>
	Assinatura  -  <a> 001 </a>
	Entrada     -  <ri>
					@IN_DATA   - Data  da taxa
					@IN_MOEDA  - Moeda da taxa                     
					</ri>
	Saida       -  <ro> @OUT_TAXA  - Taxa a ser retornada </ro>
	Autor       :  <r> Vicente Sementilli </r>
	Criacao     :  <dt> 28/07/1998 </dt>
<o>    
	Alteracao   :  Conformidade com Informix
	Autor       :  Marcelo Rodrigues de Oliveira
	Data        :  29/05/2000
</o>  

	Estrutura de chamadas
	========= == ========

	0.MAT020 - Recupera taxa para moeda na data em questao

-------------------------------------------------------------------------------------------------------------------- */

declare @DataAnt DateTime
declare @TaxaM2  float
declare @TaxaM3  float
declare @TaxaM4  float
declare @TaxaM5  float
##FIELDP06( 'SM2.M2_MOEDA6' )
declare @TaxaM6  float
##ENDFIELDP06

##FIELDP07( 'SM2.M2_MOEDA7' )
declare @TaxaM7  float
##ENDFIELDP07

##FIELDP08( 'SM2.M2_MOEDA8' )
declare @TaxaM8  float
##ENDFIELDP08

##FIELDP09( 'SM2.M2_MOEDA9' )
declare @TaxaM9  float
##ENDFIELDP09

##FIELDP10( 'SM2.M2_MOEDA10' )
declare @TaxaM10  float
##ENDFIELDP10

##FIELDP11( 'SM2.M2_MOEDA11' )
declare @TaxaM11  float
##ENDFIELDP11

##FIELDP12( 'SM2.M2_MOEDA12' )
declare @TaxaM12  float
##ENDFIELDP12

##FIELDP13( 'SM2.M2_MOEDA13' )
declare @TaxaM13  float
##ENDFIELDP13

##FIELDP14( 'SM2.M2_MOEDA14' )
declare @TaxaM14  float
##ENDFIELDP14

##FIELDP15( 'SM2.M2_MOEDA15' )
declare @TaxaM15  float
##ENDFIELDP15

##FIELDP16( 'SM2.M2_MOEDA16' )
declare @TaxaM16  float
##ENDFIELDP16

##FIELDP17( 'SM2.M2_MOEDA17' )
declare @TaxaM17  float
##ENDFIELDP17

##FIELDP18( 'SM2.M2_MOEDA18' )
declare @TaxaM18  float
##ENDFIELDP18

##FIELDP19( 'SM2.M2_MOEDA19' )
declare @TaxaM19  float
##ENDFIELDP19

##FIELDP20( 'SM2.M2_MOEDA20' )
declare @TaxaM20  float
##ENDFIELDP20

begin                

	if @IN_MOEDA is null or @IN_MOEDA = 0 select @OUT_TAXA = 1
	else begin
		/* ------------------------------------------------------------------------------
			Recupera as taxas de cada Moeda data em questao ou a mair possivel
		------------------------------------------------------------------------------ */
		select @TaxaM2 = M2_MOEDA2, @TaxaM3 = M2_MOEDA3, @TaxaM4 = M2_MOEDA4, @TaxaM5 = M2_MOEDA5
			##FIELDP06( 'SM2.M2_MOEDA6' )
			,@TaxaM6 = M2_MOEDA6
			##ENDFIELDP06

			##FIELDP07( 'SM2.M2_MOEDA7' )
			,@TaxaM7 = M2_MOEDA7
			##ENDFIELDP07

			##FIELDP08( 'SM2.M2_MOEDA8' )
			,@TaxaM8 = M2_MOEDA8
			##ENDFIELDP08

			##FIELDP09( 'SM2.M2_MOEDA9' )
			,@TaxaM9 = M2_MOEDA9
			##ENDFIELDP09

			##FIELDP10( 'SM2.M2_MOEDA10' )
			,@TaxaM10 = M2_MOEDA10
			##ENDFIELDP10

			##FIELDP11( 'SM2.M2_MOEDA11' )
			,@TaxaM11 = M2_MOEDA11
			##ENDFIELDP11

			##FIELDP12( 'SM2.M2_MOEDA12' )
			,@TaxaM12 = M2_MOEDA12
			##ENDFIELDP12

			##FIELDP13( 'SM2.M2_MOEDA13' )
			,@TaxaM13 = M2_MOEDA13
			##ENDFIELDP13

			##FIELDP14( 'SM2.M2_MOEDA14' )
			,@TaxaM14 = M2_MOEDA14
			##ENDFIELDP14

			##FIELDP15( 'SM2.M2_MOEDA15' )
			,@TaxaM15 = M2_MOEDA15
			##ENDFIELDP15

			##FIELDP16( 'SM2.M2_MOEDA16' )
			,@TaxaM16 = M2_MOEDA16
			##ENDFIELDP16

			##FIELDP17( 'SM2.M2_MOEDA17' )
			,@TaxaM17 = M2_MOEDA17
			##ENDFIELDP17

			##FIELDP18( 'SM2.M2_MOEDA18' )
			,@TaxaM18 = M2_MOEDA18
			##ENDFIELDP18

			##FIELDP19( 'SM2.M2_MOEDA19' )
			,@TaxaM19 = M2_MOEDA19
			##ENDFIELDP19

			##FIELDP20( 'SM2.M2_MOEDA20' )
			,@TaxaM20 = M2_MOEDA20
			##ENDFIELDP20


		from SM2### 
		where M2_DATA = (select MAX(substring(M2_DATA,1,8))
						from SM2### 
						where M2_DATA <= @IN_DATA  and  D_E_L_E_T_ = ' ')
						and D_E_L_E_T_ = ' '

		select @OUT_TAXA = 1

		if      @IN_MOEDA = 2 select @OUT_TAXA = @TaxaM2
		else if @IN_MOEDA = 3 select @OUT_TAXA = @TaxaM3
		else if @IN_MOEDA = 4 select @OUT_TAXA = @TaxaM4
		else if @IN_MOEDA = 5 select @OUT_TAXA = @TaxaM5

		##FIELDP06( 'SM2.M2_MOEDA6' )		
		else if @IN_MOEDA = 6 select @OUT_TAXA = @TaxaM6
		##ENDFIELDP06

		##FIELDP07( 'SM2.M2_MOEDA7' )		
		else if @IN_MOEDA = 7 select @OUT_TAXA = @TaxaM7
		##ENDFIELDP07

		##FIELDP08( 'SM2.M2_MOEDA8' )		
		else if @IN_MOEDA = 8 select @OUT_TAXA = @TaxaM8
		##ENDFIELDP08

		##FIELDP09( 'SM2.M2_MOEDA9' )		
		else if @IN_MOEDA = 9 select @OUT_TAXA = @TaxaM9
		##ENDFIELDP09

		##FIELDP10( 'SM2.M2_MOEDA10' )		
		else if @IN_MOEDA = 10 select @OUT_TAXA = @TaxaM10
		##ENDFIELDP10

		##FIELDP11( 'SM2.M2_MOEDA11' )		
		else if @IN_MOEDA = 11 select @OUT_TAXA = @TaxaM11
		##ENDFIELDP11

		##FIELDP12( 'SM2.M2_MOEDA12' )		
		else if @IN_MOEDA = 12 select @OUT_TAXA = @TaxaM12
		##ENDFIELDP12

		##FIELDP13( 'SM2.M2_MOEDA13' )		
		else if @IN_MOEDA = 13 select @OUT_TAXA = @TaxaM13
		##ENDFIELDP13

		##FIELDP14( 'SM2.M2_MOEDA14' )		
		else if @IN_MOEDA = 14 select @OUT_TAXA = @TaxaM14
		##ENDFIELDP14

		##FIELDP15( 'SM2.M2_MOEDA15' )		
		else if @IN_MOEDA = 15 select @OUT_TAXA = @TaxaM15
		##ENDFIELDP15

		##FIELDP16( 'SM2.M2_MOEDA16' )		
		else if @IN_MOEDA = 16 select @OUT_TAXA = @TaxaM16
		##ENDFIELDP16

		##FIELDP17( 'SM2.M2_MOEDA17' )		
		else if @IN_MOEDA = 17 select @OUT_TAXA = @TaxaM17
		##ENDFIELDP17

		##FIELDP18( 'SM2.M2_MOEDA18' )		
		else if @IN_MOEDA = 18 select @OUT_TAXA = @TaxaM18
		##ENDFIELDP18

		##FIELDP19( 'SM2.M2_MOEDA19' )
		else if @IN_MOEDA = 19 select @OUT_TAXA = @TaxaM19
		##ENDFIELDP19

		##FIELDP20( 'SM2.M2_MOEDA20' )
		else if @IN_MOEDA = 20 select @OUT_TAXA = @TaxaM20
		##ENDFIELDP20

		If @OUT_TAXA is null select @OUT_TAXA = 1

	end
end
