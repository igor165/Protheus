Create procedure CTB196_##
(
@IN_RECMIN       Integer ,
@IN_RECMAX       Integer ,
@IN_FILIAL       Char('CT2_FILIAL'),
@OUT_RESULTADO   Char(01) OutPut
)
as

/* ------------------------------------------------------------------------------------
Versão          - <v> Protheus P12 </v>
Assinatura      - <a>  001 </a>
Procedure       -     Reprocessamento SigaCTB
	Descricao       - <d> Zera a fila </d>
	Funcao do Siga  -     CtbZeraTod()
	Fonte Microsiga - <s> CTBA193.PRW </s>
	Entrada         - <ri> @IN_RECMIN       - Recno Inicial da CQA
	@IN_RECMAX       - Recno Final da CQA
	</ri>
	Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
	Responsavel :     <r> Alvaro Camillo Neto	</r>
	Data        :     19/09/2003
	-------------------------------------------------------------------------------------- */
	declare @iMinRecno    integer
	declare @iMaxRecno    integer
   declare @cFilial_CQA char('CT2_FILIAL')
   declare @cFILCQA     char('CT2_FILIAL')
   declare @cAux        char(03)

	begin
      select @cFILCQA = ' '
   
      If @IN_FILIAL = ' ' select @cFILCQA = ' '
      else select @cFILCQA = @IN_FILIAL
   
      select @cAux = 'CQA'
      exec XFILIAL_## @cAux, @cFILCQA, @cFilial_CQA OutPut
		/* -------------------------------------------------------------------------
		Zera as tabelas de fila CQA
		-------------------------------------------------------------------------*/
      select @iMinRecno = @IN_RECMIN
      select @iMaxRecno = @IN_RECMAX
		
      if @iMinRecno != 0 begin
		      /* ----------------------
		      Exclui fisicamente      
		      ---------------------- */
		      Begin tran
			      Update CQA###
			      Set D_E_L_E_T_ = '*'
			      ##FIELDP01( 'CQA.R_E_C_D_E_L_' )
			      , R_E_C_D_E_L_ = R_E_C_N_O_
			      ##ENDFIELDP01
			      where CQA_FILIAL = @cFilial_CQA
                  and D_E_L_E_T_ = ' '
                  and R_E_C_N_O_ between @iMinRecno and @iMaxRecno
		      commit tran
	      end
	      select @OUT_RESULTADO = '1'
      end

	


