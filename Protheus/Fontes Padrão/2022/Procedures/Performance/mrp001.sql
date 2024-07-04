Create procedure MRP001_## 
  (
    @IN_FILIALHWA  Char('HWA_FILIAL'),
	@IN_FILIALT4N  Char('T4N_FILIAL'),
	@IN_FILIALSMB  Char('T4N_FILIAL'),
	@IN_GRAVASMB   Char(01),
    @OUT_RESULTADO Char(01)  OUTPUT
  )
As
/* ------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> MRPPROCED.PRW </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Atualiza a coluna HWA_NIVEL de acordo com a T4N </d>
    Entrada     -  <ri> 
	               @IN_FILIALHWA  - Filial Tabela HWA
				   @IN_FILIALT4N  - Filial Tabela T4N
				   @IN_FILIALSMB  - Filial Tabela SMB
				   @IN_GRAVASMB   - Indica se deve gravar a tabela SMB
	               </ri>
    Saida       -  <ro> @OUT_RESULTADO - Retorna o status do Resultado </ro>
    Responsavel :  <r> Marcelo Neumann </r>
    Data        :  <dt> 12/11/2019 </dt> 
----------------------------------------------------------------------------- */
Declare @cNivel       VarChar('HWA_NIVEL')
Declare @cNivelAnt    VarChar('HWA_NIVEL')
Declare @iCount       Integer
Declare @iNivel       Integer

Select @OUT_RESULTADO = '0'

Begin Tran
/* -----------------------------------------
  Atualiza todos os produtos para nivel 02
----------------------------------------- */
Update HWA###
   Set HWA_NIVEL  = '02'
 Where HWA_FILIAL = @IN_FILIALHWA
   And D_E_L_E_T_ = ' ' 

/* -----------------------------------------
  Atualiza os PAs com o nivel 01
----------------------------------------- */
Update HWA###
   Set HWA_NIVEL  = '01'
 Where HWA_FILIAL = @IN_FILIALHWA 
   And D_E_L_E_T_ = ' ' 
   And Not Exists (Select 1
                     From T4N### T4N (nolock)
                    Where T4N.T4N_FILIAL = @IN_FILIALT4N 
                      And T4N.T4N_COMP   = HWA_PROD
                      And T4N.D_E_L_E_T_ = ' ')
Commit Tran

/* -----------------------------------------
  Inicializa o nivel da Atualizacao
----------------------------------------- */
Select @iNivel = 2
Select @cNivel = '02'

/* --------------------------------------------------
  Loop ate o ultimo nivel possivel das estruturas
-------------------------------------------------- */
While 1=1 Begin
	/* --------------------------------------------------------
	  Verifica se existem produtos no nivel corrente
	-------------------------------------------------------- */
	Select @iCount = Count(*)
	  From HWA### (nolock)
	 Where HWA_FILIAL = @IN_FILIALHWA
	   And HWA_NIVEL  = @cNivel
	   And D_E_L_E_T_ = ' '

	If (@iCount = 0)  Break

	/* --------------------------------------------------------
	  Salva o ultimo nivel atualizado
	-------------------------------------------------------- */
	Select @cNivelAnt = @cNivel

	/* --------------------------------------------------------
	  Ajusta o tipo do Nivel para Caracter
	-------------------------------------------------------- */
	Select @iNivel = @iNivel + 1
	Select @cNivel = Convert(VarChar(2),@iNivel)

	If @iNivel <= 9  Select @cNivel = '0' || @cNivel

	/* -------------------------------------------------------------------
	  Adiciona nivel no componente em que seu pai esta no nivel anterior
	------------------------------------------------------------------- */
	Begin Tran
	Update HWA###
	   Set HWA_NIVEL  = @cNivel
	 Where HWA_FILIAL = @IN_FILIALHWA
	   And D_E_L_E_T_ = ' ' 
	   And Exists (Select 1
	                 From T4N### T4N (nolock)
	                Where T4N.T4N_FILIAL = @IN_FILIALT4N
	                  And T4N.T4N_COMP   = HWA_PROD
	                  And T4N.D_E_L_E_T_ = ' '
	                  And Exists (Select 1
	                                From HWA### PAI (nolock)
	                               Where PAI.HWA_FILIAL = @IN_FILIALHWA
	                                 And PAI.HWA_PROD   = T4N.T4N_PROD
	                                 And PAI.HWA_NIVEL  = @cNivelAnt))
	Commit Tran
End

/* -----------------------------------------
  Atualiza os MPs com o nivel 99
----------------------------------------- */
Begin Tran
Update HWA###
   Set HWA_NIVEL  = '99'
 Where HWA_FILIAL = @IN_FILIALHWA
   And D_E_L_E_T_ = ' '
   And Not Exists (Select 1
                     From T4N### T4N (nolock)
                    Where T4N.T4N_FILIAL = @IN_FILIALT4N
                      And T4N.T4N_PROD   = HWA_PROD
                      And T4N.D_E_L_E_T_ = ' ')
Commit Tran

/* -----------------------------------------
  Grava a tabela de níveis por filial
----------------------------------------- */
##FIELDP02( 'SMB.MB_FILIAL' )
If @IN_GRAVASMB = '1' Begin
	Begin Tran
	INSERT INTO SMB###(MB_FILIAL, MB_PROD, MB_NIVEL)
	 SELECT @IN_FILIALSMB, HWA.HWA_PROD, HWA.HWA_NIVEL
	   FROM HWA### HWA
	  WHERE HWA.HWA_FILIAL = @IN_FILIALHWA
	    AND HWA.HWA_NIVEL  <> '99'
	    AND HWA.D_E_L_E_T_ = ' '
	Commit Tran
End
##ENDFIELDP02

Select @OUT_RESULTADO = '1'
