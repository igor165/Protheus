#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'

/*/{Protheus.doc} MATA010DPR
Classe de eventos relacionados com produto x sigaDPR e produto x sigaSFC

@author Juliane Venteu
@since 02/03/2017
@version P12.1.17

/*/
CLASS MATA010DPR FROM FWModelEvent

	DATA nOpc
	DATA oModelSFC
	DATA cNome
	DATA cError

	METHOD New() CONSTRUCTOR
	METHOD InTTS()
	METHOD ModelPosVld()
	METHOD Destroy()

	METHOD Exec()
	METHOD getError()

ENDCLASS

//-----------------------------------------------------------------
METHOD New(oModelBase, cNome, cError) CLASS MATA010DPR

	If oModelBase <> NIL
		::oModelSFC := oModelBase
	EndIf

	::cNome := cNome
	::cError := cError
	::nOpc := NIL
Return

/*/{Protheus.doc} ModelPosVld
Esse metodo ativa o modelo de dados, inputa os dados do produto e valida

@author Juliane Venteu
@since 02/03/2017
@version P12.1.17

/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA010DPR
	Local aArea   := GetArea()	// Salva area atual para posterior restauracao
	Local aCampos := {}			// Array dos campos a serem atualizados pelo modelo
	Local aAux    := {}			// Array auxiliar com o conteudo dos campos
	Local lRet    := .T.
	Local lExiste := .F.
	Local nX	  := 0			// Indexadora de laco For/Next
	Local cProd   := ""
	Local cDesc   := ""
	Local cUM     := ""
	Local cGrupo  := ""
	Local cTipo   := ""
	Local cLocPad := ""
	Local nLE     := 0
	Local nLM     := 0
	Local nPesBru := 0
	Local nPeso   := 0
	Local oModSB1 := Nil //oModel:GetModel("SB1MASTER")

	If oModel == Nil
		cProd   := M->B1_COD
		cDesc   := M->B1_DESC
		cUM     := M->B1_UM
		cGrupo  := M->B1_GRUPO
		cTipo   := M->B1_TIPO
		cLocPad := M->B1_LOCPAD
		nLE     := M->B1_LE
		nLM     := M->B1_LM
		nPesBru := M->B1_PESBRU
		nPeso   := M->B1_PESO
	Else
		oModSB1 := oModel:GetModel("SB1MASTER")
		cProd   := oModSB1:GetValue("B1_COD"   )
		cDesc   := oModSB1:GetValue("B1_DESC"  )
		cUM     := oModSB1:GetValue("B1_UM"    )
		cGrupo  := oModSB1:GetValue("B1_GRUPO" )
		cTipo   := oModSB1:GetValue("B1_TIPO"  )
		cLocPad := oModSB1:GetValue("B1_LOCPAD")
		nLE     := oModSB1:GetValue("B1_LE"    )
		nLM     := oModSB1:GetValue("B1_LM"    )
		nPesBru := oModSB1:GetValue("B1_PESBRU")
		nPeso   := oModSB1:GetValue("B1_PESO"  )
	EndIf

	If ::nOpc == NIL
		::nOpc := oModel:GetOperation()
	EndIf

	//Posiciona na CZ3 se não for operação de inclusão.
	If ::nOpc <> MODEL_OPERATION_INSERT
		CZ3->(DBSetOrder(1))
		lExiste := CZ3->(DBSeek(xFilial("CZ3")+cProd))
	EndIf

	//Se é DELETE e o produto não existe na CZ3, não precisa continuar com a integração.
	If ::nOpc == MODEL_OPERATION_DELETE .And. !lExiste
		RestArea(aArea)
		Return .T.
	EndIf

	//Instancia o modelo do SFC se ainda não estiver instanciado.
	If ::oModelSFC == NIL
		::oModelSFC := FWLoadModel("SFCC101")
	EndIf

	If ::oModelSFC:lActivate
		::oModelSFC:Deactivate()
	EndIf

	//Se for INCLUSÃO ou se o produto não existir na CZ3, adiciona os campos principais.
	If ::nOpc == MODEL_OPERATION_INSERT .Or. !lExiste
		aAdd(aCampos,{"CZ3_FILIAL", xFilial("CZ3") })
		aAdd(aCampos,{"CZ3_CDAC"  , cProd          })
		aAdd(aCampos,{"CZ3_DTBG"  , dDataBase      })
		aAdd(aCampos,{"CZ3_TPAC"  , "1"            })
	EndIf

	//Adiciona os demais campos quando não for operação de exclusão
	If ::nOpc <> MODEL_OPERATION_DELETE
		aAdd(aCampos,{"CZ3_DSAC"  , cDesc  })
		aAdd(aCampos,{"CZ3_CDUN"  , cUM    })
		aAdd(aCampos,{"CZ3_CDGR"  , cGrupo })
		aAdd(aCampos,{"CZ3_CDFA"  , cTipo  })
		aAdd(aCampos,{"CZ3_CDDP"  , cLocPad})
		aAdd(aCampos,{"CZ3_QTLOEC", nLE    })
		aAdd(aCampos,{"CZ3_QTLOMI", nLM    })
		aAdd(aCampos,{"CZ3_VLPSBR", nPesBru})
		aAdd(aCampos,{"CZ3_VLPSLQ", nPeso  })
	EndIf

	If !lExiste .And. ::nOpc == MODEL_OPERATION_UPDATE
		//Se o produto não existe na CZ3, utiliza operação de inclusão.
		::oModelSFC:SetOperation(MODEL_OPERATION_INSERT)
	Else
		::oModelSFC:SetOperation(::nOpc)
	EndIf

	//Ativa o modelo de dados
	If (lRet := ::oModelSFC:Activate())
		//Obtem a estrutura de dados do Model
		aAux := ::oModelSFC:GetModel("CZ3MASTER"):GetStruct():GetFields()

		//Loop para validacao e atribuicao de dados dos campos do Model
		For nX := 1 To Len(aCampos)
			//Valida os campos existentes na estrutura do Model
			If aScan(aAux,{|x| AllTrim(x[3]) ==  AllTrim(aCampos[nX,1])}) > 0
				//Atribui os valores aos campos do Model caso passem pela validacao do formulario
				//referente a tipos de dados, tamanho ou outras incompatibilidades estruturais.
				If !(::oModelSFC:SetValue("CZ3MASTER",aCampos[nX,1],aCampos[nX,2]))
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nX
	Endif

	If lRet
		If ::oModelSFC:VldData()
			::InTTS()
		Else
			lRet := .F.
		EndIf
	EndIf

	//Gera log de erro caso nao tenha passado pela validacao
	If !lRet
		A010SFCErr(::oModelSFC, @::cError, NIL, ::cNome, cProd)
	EndIf

	If oModel <> NIL
		FwModelActive(oModel)
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} InTTS
Realiza a gravação da integração

@author Juliane Venteu
@since 02/03/2017
@version P12.1.17

/*/
METHOD InTTS(oModel, cID) CLASS MATA010DPR
	If ::oModelSFC <> Nil .And. ::oModelSFC:lActivate
		::oModelSFC:CommitData()
		::oModelSFC:DeActivate()
	EndIF
Return

/*/{Protheus.doc} Destroy
//TODO Destroi o objeto
@author reynaldo
@since 04/12/2017
@version 1.0
@return ${return}, ${return_description}

@type method
/*/
METHOD Destroy() CLASS MATA010DPR
	If ::oModelSFC <> NIL
		::oModelSFC:Deactivate()
		::oModelSFC:Destroy()
	EndIf
Return

/*/{Protheus.doc} Exec
Esse metodo foi criado devido para a função A010IntSFC que chama a integração
sem usar o modelo de dados MATA010.

Como a integração esta isolada aqui nessa classe, esse metodo foi criado
para que a função possa usar o objeto de integração.

@author Juliane Venteu
@since 02/03/2017
@version P12.1.17
@return lRet, logic, Retorna se o processo ocorreu corretamente
/*/
METHOD Exec(nOpc) CLASS MATA010DPR
	Local lRet := .T.

	::nOpc := nOpc
	lRet := ::ModelPosVld()
	If lRet
		::InTTS()
	EndIf

Return lRet

METHOD getError() CLASS MATA010DPR
Return ::cError
