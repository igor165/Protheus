#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

CLASS VEIA111EVDEF FROM FWModelEvent
	Data cFilCpoSA1
	
	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
ENDCLASS

METHOD New() CLASS VEIA111EVDEF
	
RETURN

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA111EVDEF

	Local nOperation := oModel:GetOperation()
	Local oModelVJP := oModel:GetModel("MODEL_VJP")
	Local oModelSA1 := oModel:GetModel("MODEL_SA1")

	Local aDadosA1 := {}
	Local rs
	Local lRet := .t.

	Local aCpoSA1 := StrtokArr( ::cFilCpoSA1, "|")
	Local nPosCpoSA1

	Private lMSHelpAuto := .t.
	Private lMsErroAuto := .f.
	
	If nOperation == MODEL_OPERATION_UPDATE

		If AllTrim(oModelVJP:GetValue("FUNCAO")) == "CRIARSA1"

			For nPosCpoSA1 := 1 to Len(aCpoSA1)
				If ! Empty(oModelSA1:GetValue( AllTrim(aCpoSA1[nPosCpoSA1]) ))
					AADD( aDadosA1 , { AllTrim(aCpoSA1[nPosCpoSA1]) , oModelSA1:GetValue( AllTrim(aCpoSA1[nPosCpoSA1]) ) , NIL } ) 
				EndIf
			Next nPosCpoSA1

			Begin Transaction
			Begin Sequence
			
				MsExecAuto({|x,y| MATA030(x,y)}, aDadosA1, 3)
				
				IF lMsErroAuto	
					For rs := 1 to len(aDadosA1)
						AutoGrLog( " " + aDadosA1[rs,1] + ": [" + cValToChar(aDadosA1[rs,2]) + "]" )
					Next rs	
					DisarmTransaction()	
					RollBackSX8()
					MostraErro()
					Break
					
				Else
					ConfirmSX8()
				EndIf

				oModelVJP:SetValue("VJP_A1FIL"  , FWxFilial("SA1") )
				oModelVJP:SetValue("VJP_A1COD"  , oModelSA1:GetValue("A1_COD"))
				oModelVJP:SetValue("VJP_A1LOJA" , oModelSA1:GetValue("A1_LOJA"))

				// Verificar todos as Cotações que tenham o mesmo ID de cliente da JD e 
				// atualizar as possiveis Oportunidades/Atendimentos já gerados ...
				BeginSql Alias "TPESQQUOTE"

					COLUMN VJJREC AS NUMERIC(10,0)

					SELECT VJJ.R_E_C_N_O_ VJJREC,
						VJK.VJK_FILOPO, 
						VJK.VJK_CODOPO, 
						VJK.VJK_NUMTRA
					  FROM %Table:VJJ% VJJ
						JOIN %Table:VJK% VJK 
							ON VJK.VJK_FILIAL = %xfilial:VJK%
							AND VJK.VJK_CODVJJ = VJJ.VJJ_CODIGO
							AND VJK.%NotDel%
					WHERE VJJ.VJJ_FILIAL = %xfilial:VJJ%
					  AND VJJ.VJJ_CODVJP = %exp:oModelVJP:GetValue('VJP_CODIGO')%
					  AND ( VJK.VJK_CODOPO <> ' ' OR VJK.VJK_NUMTRA <> ' ' )
					  AND VJJ.%NotDel%

				EndSql

				While !TPESQQUOTE->(Eof())

					VJJ->(dbGoTo( TPESQQUOTE->VJJREC ))
					RecLock("VJJ",.F.)
					VJJ->VJJ_CODVJP := " "
					VJJ->(MsUnLock())

					If ! Empty(TPESQQUOTE->VJK_CODOPO)

						VDL->(dbSetOrder(1))
						If VDL->(dbSeek(TPESQQUOTE->VJK_FILOPO + TPESQQUOTE->VJK_CODOPO))
							Reclock("VDL",.f.)
							VDL->VDL_CODCLI := SA1->A1_COD 
							VDL->VDL_LOJCLI := SA1->A1_LOJA
							VDL->VDL_NOMCLI := SA1->A1_NOME
							VDL->VDL_DDDCLI := SA1->A1_DDD
							VDL->VDL_TELCLI := SA1->A1_TEL
							VDL->VDL_EMACLI := SA1->A1_EMAIL
							//VDL->VDL_NIVIMP := cNivImp
							VDL->(MsUnLock())
						EndIf
						
					EndIf

					If ! Empty(TPESQQUOTE->VJK_NUMTRA)

						
					EndIf

					TPESQQUOTE->(dbSkip())
				End

				TPESQQUOTE->(dbCloseArea())


			Recover
				DisarmTransaction()
				RollBackSX8()
				MsUnlockAll()
				MostraErro()

				lRet := .f.

			End Sequence
			End Transaction

		EndIf
	EndIf

RETURN lRet
