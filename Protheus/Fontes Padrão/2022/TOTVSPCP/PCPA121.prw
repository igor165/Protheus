#INCLUDE "PROTHEUS.CH"

Function PCPA121()
Return Nil

/*/{Protheus.doc} PCPA121vld

Função que valida os campos

@param cCampo		- Campo da tabela SOX que será validado.
@param cConteudo	- Conteúdo do campo da tabela SOX para validação.
@param nOper		- Operação que está sendo executada. (3=Inclusão; 4=Alteração; 5=Exclusão; 1=Pesquisa)
@param cCodForm		- Código do formulário.

@return lRet - Lógico, indicando se o valor é válido para o campo ou não.

@author  Michelle Ramos Henriques
@version P12
@since   26/04/2018
/*/
Function PCPA121Vld(cCampo,cConteudo,nOper,cCodForm)
	Local lRet := .T.
	
	dbSelectArea("SOX")
	lExisOxPar := If (SOX->(ColumnPos("OX_PARADA")) >  0, .T., .F.)
	lExisOxCro := If (SOX->(ColumnPos("OX_CRONOM")) >  0, .T., .F.)

	If cCampo == "OX_PARADA" .And. !lExisOxPar
		Return .T.
	EndIf

	If cCampo == 'OX_CRONOM' .And. !lExisOxCro
		Return .T.
	EndIf

	If cCampo == 'OX_TPPROG' .And. !lExisOxCro
		Return .T.
	EndIf
	
	cConteudo := PADR(cConteudo, TamSX3(cCampo)[1])
	cCodForm := PADR(cCodForm, TamSX3("OX_FORM")[1])

	If nOper == 3  
		If cCampo == "OX_FORM" .And. !Empty(cConteudo)
			SOX->(dbSetOrder(1))
			If SOX->(dbSeek(xFilial("SOX")+cConteudo))
				lRet := .F.
			EndIf
		EndIf

		If cCampo == "OX_PRGAPON" .And. !Empty(cConteudo)
			If cConteudo != '1' .And. cConteudo != '2'  .And. cConteudo != '3'  .And. cConteudo != '4'
				lRet := .F.
			EndIf
		EndIf

		If cCampo == "OX_PARADA" .And. !Empty(cConteudo) .And. Empty(cCodForm)
			If cConteudo != '1' .And. cConteudo != '2'  
				lRet := .F.
			EndIf
		EndIf

		If cCampo == "OX_PARADA" .And. !Empty(cConteudo) .And. !Empty(cCodForm)
			If cCodForm != '4'
				lRet := .F.
			EndIf
		EndIf

		If cCampo == "OX_CRONOM" .And. !Empty(cConteudo) .And. Empty(cCodForm)
			If cConteudo != '1' .And. cConteudo != '2'  
				lRet := .F.
			EndIf
		EndIf

		If cCampo == "OX_CRONOM" .And. !Empty(cConteudo) .And. !Empty(cCodForm)
			If cCodForm != '4'
				lRet := .F.
			EndIf
		EndIf	

		If cCampo == "OX_TPPROG" .And. !Empty(cConteudo) .And. Empty(cCodForm)
			If cConteudo != '1' .And. cConteudo != '2'  .And. cConteudo != '3'  
				lRet := .F.
			EndIf
		EndIf	

		If cCampo == "OX_TPPROG" .And. !Empty(cConteudo) .And. !Empty(cCodForm)
			If cCodForm != '1'
				lRet := .F.
			EndIf
		EndIf	
	EndIf

	If nOper == 4
		If cCampo == "OX_FORM" .And. !Empty(cConteudo)
			SOX->(dbSetOrder(1))
			If !SOX->(dbSeek(xFilial("SOX")+cConteudo))
				lRet := .F.              
			EndIf
		EndIf
      
		If cCampo == "OX_PRGAPON" .And. !Empty(cConteudo)	
			SOX->(dbSetOrder(1))
			SOX->(dbSeek(xFilial("SOX")+cCodForm))
			If SOX->OX_PRGAPON <> cConteudo 
				lRet := .F.
			EndIf 
		EndIf
	EndIf

	If nOper == 5
		SOX->(dbSetOrder(1))

		If cCampo == "OX_FORM" .And. !Empty(cConteudo)
			If !SOX->(dbSeek(xFilial("SOX")+cConteudo))
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121Tam

Função que valida se as informações passadas estão de acordo com o tamanho do campo no dicionário

@param cCampo		- Campo da tabela SOX.
@param cConteudo	- Conteúdo do campo que será validado.

@return lRet	- Indica se o tamanho do conteúdo está valido para o campo.

@author  Michelle Ramos Henriques
@version P12
@since   26/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA121Tam(cCampo,cConteudo)
	Local lRet := .T.
	
	If cCampo == "OX_PRGAPON" .and. !empty(cConteudo)  
		If Len(cConteudo) > TamSX3("OX_PRGAPON")[1]
			lRet := .F.
		EndIf
	EndIf

	If cCampo == "OX_FORM" .and. !empty(cConteudo)  
		If Len(cConteudo) > TamSX3("OX_FORM")[1]
			lRet := .F.
		EndIf
	EndIf

	If cCampo == "OX_IMAGEM" .and. !empty(cConteudo)  
		If Len(cConteudo) > TamSX3("OX_IMAGEM")[1]
			lRet := .F.
		EndIf
	EndIf

	If cCampo == "OX_DESCR" .and. !empty(cConteudo)  
		If Len(cConteudo) > TamSX3("OX_DESCR")[1]
			lRet := .F.
		EndIf
	EndIf

return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121In

Função que inclui o registro

@param aSOX - Array com as informações da tabela SOX. 

@return lRet - Indica se a inclusão do registro foi realizada corretamente.

@author  Michelle Ramos Henriques
@version P12
@since   26/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA121In(aSOX)
	Local lRet		:= .T.
	Local nPosForm	:= ASCAN(aSOX,{|x| x[1] == "OX_FORM"})
	Local nPosPrgAp	:= ASCAN(aSOX,{|x| x[1] == "OX_PRGAPON"})
	Local nPosImg	:= ASCAN(aSOX,{|x| x[1] == "OX_IMAGEM"})
	Local nPosDsc	:= ASCAN(aSOX,{|x| x[1] == "OX_DESCR"})
	Local nPosPar	:= ASCAN(aSOX,{|x| x[1] == "OX_PARADA"})
	Local nPosCro   := ASCAN(aSOX,{|x| x[1] == "OX_CRONOM"})
	Local nPosPro   := ASCAN(aSOX,{|x| x[1] == "OX_TPPROG"})
	
	If nPosForm < 1 .Or. nPosPrgAp < 1 .Or. nPosImg < 1 .Or. nPosDsc < 1
		lRet := .F.
	Else
		dbSelectArea("SOX")
		lExisOxPar := If (SOX->(ColumnPos("OX_PARADA")) >  0, .T., .F.)
		lExisOxCro := If (SOX->(ColumnPos("OX_CRONOM")) >  0, .T., .F.)

		Reclock("SOX",.T.)
			SOX->OX_FILIAL  := xFilial("SOX")
			SOX->OX_FORM    := aSOX[nPosForm,2]
			SOX->OX_PRGAPON := aSOX[nPosPrgAp,2]
			SOX->OX_IMAGEM  := aSOX[nPosImg,2]
			SOX->OX_DESCR   := aSOX[nPosDsc,2]

			If lExisOxPar
				If aSOX[nPosPrgAp,2] = '4' .And. !Empty(aSOX[nPosPar,2])  //Parada somente será gravado quando for apontamento via SFC
					SOX->OX_PARADA   := aSOX[nPosPar,2]
				EndIf
			EndIf

			If lExisOxCro
				If aSOX[nPosPrgAp,2] = '4' .And. !Empty(aSOX[nPosCro,2])  //Cronometro somente será gravado quando for apontamento via SFC
					SOX->OX_CRONOM   := aSOX[nPosCro,2]
				EndIf

				If aSOX[nPosCro,2] = '1' .And. !Empty(aSOX[nPosPro,2]) //Tipo de Progresso somente será gravado quando Cronometro = 1 - Sim
					SOX->OX_TPPROG   := aSOX[nPosPro,2]
				EndIf
			EndIf
			
		MsUnLock()
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121Atu

Função que atualiza o registro

@param aSOX	- Array com os dados para atualização da tabela SOX.

@return lRet	- Indicador se a atualização foi realizada.

@author  Michelle Ramos Henriques
@version P12
@since   26/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA121Atu(aSOX)
	Local lRet := .T.
	Local nPosForm	:= ASCAN(aSOX,{|x| x[1] == "OX_FORM"})
	Local nPosPrgAp	:= ASCAN(aSOX,{|x| x[1] == "OX_PRGAPON"})
	Local nPosImg	:= ASCAN(aSOX,{|x| x[1] == "OX_IMAGEM"})
	Local nPosDsc	:= ASCAN(aSOX,{|x| x[1] == "OX_DESCR"})
	Local nPosPar	:= ASCAN(aSOX,{|x| x[1] == "OX_PARADA"})
	Local nPosCro   := ASCAN(aSOX,{|x| x[1] == "OX_CRONOM"})
	Local nPosPro   := ASCAN(aSOX,{|x| x[1] == "OX_TPPROG"})
	
	If nPosForm < 1 .Or. nPosPrgAp < 1 .Or. nPosImg < 1 .Or. nPosDsc < 1
		lRet := .F.
	Else
		aSOX[nPosForm,2] := PADR(aSOX[nPosForm,2], tamSX3("OX_FORM")[1])

		dbSelectArea("SOX")
		lExisOxPar := If (SOX->(ColumnPos("OX_PARADA")) >  0, .T., .F.)
		lExisOxCro := If (SOX->(ColumnPos("OX_CRONOM")) >  0, .T., .F.)
	 
		SOX->(dbSetOrder(1))
		If SOX->(dbSeek(xFilial("SOX")+aSOX[nPosForm,2]))
			Reclock("SOX",.F.)
				Replace SOX->OX_IMAGEM  With aSOX[nPosImg,2]
				Replace SOX->OX_DESCR   With aSOX[nPosDsc,2]

				If lExisOxPar
					If aSOX[nPosPrgAp,2] = '4' .And. !Empty(aSOX[nPosPar,2])  //Parada somente será gravado quando for apontamento via SFC
						SOX->OX_PARADA   := aSOX[nPosPar,2]
					EndIf
				EndIf

				If lExisOxCro
					If aSOX[nPosPrgAp,2] = '4' .And. !Empty(aSOX[nPosCro,2])  //Cronometro somente será gravado quando for apontamento via SFC
						SOX->OX_CRONOM   := aSOX[nPosCro,2]
						SOX->OX_TPPROG   := aSOX[nPosPro,2]
					EndIf					
				EndIf
			MsUnlock()
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121Del

Função que deleta o registro

@param cCodForm	- Código do formulário que será excluído.

@return lRet	- Indica se o registro foi ou não excluído.

@author  Michelle Ramos Henriques
@version P12
@since   26/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA121Del(cCodForm)
	Local lRet := .T.
	
	cCodForm := PADR(cCodForm, tamSX3("OX_FORM")[1])	

	SOX->(dbSetOrder(1))
	If SOX->(dbSeek(xFilial("SOX")+cCodForm))
		If Reclock("SOX",.F.)
			dbDelete()
			MsUnlock()
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121Con

Função para consultar se o registro já existe na base de dados

@author  Michelle Ramos Henriques
@version P12
@since   26/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA121Con(cCode,nStart, nCount, nPage)

Local nX          := 0
Local cQuery      := ""
Local cAliasTemp  := ""
Local nRegSOX     := 0
Local aSOX        := {}

Default nStart := 1
Default nCount := 20
Default nPage  := 0

dbSelectArea('SOX')
lExisOxPar := If (SOX->(ColumnPos("OX_PARADA")) >  0, .T., .F.)
lExisOxCro := If (SOX->(ColumnPos("OX_CRONOM")) >  0, .T., .F.)

SOX->(dbSetOrder(1))

If !Empty(cCode)
	cCode := PadR(cCode, TamSX3("OX_FORM")[1])
	If SOX->(dbSeek(xFilial("SOX")+cCode))
		cParada := ' '
		cCronom := ' '
		cTpProg := ' '
		
		If lExisOxPar
			cParada := SOX->OX_PARADA
		EndIf

		If lExisOxCro
			cCronom := SOX->OX_CRONOM
			cTpProg := SOX->OX_TPPROG
		EndIf

     	aAdd(aSOX,{SOX->OX_FORM,SOX->OX_PRGAPON,SOX->OX_IMAGEM,SOX->OX_DESCR,cParada,cCronom,cTpProg})		
	EndIf
Else
	If nPage > 0 
		cAliasTemp:= "SOXTMP"
		cQuery      := "  SELECT COUNT(*) AS RegSOX "
		cQuery      += "   FROM " + RetSqlName('SOX') + " SOX "
		cQuery      += "   WHERE SOX.OX_FILIAL   = '" + xFilial("SOX") + "'"
		cQuery      += "     AND SOX.D_E_L_E_T_  = ' '"
		cQuery    := ChangeQuery(cQuery)
		dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

		If !(cAliasTemp)->(Eof())
			nRegSOX := (cAliasTemp)->RegSOX
		EndIf

		(cAliasTemp)->(DBCloseArea())
	EndIf

	If nStart == 1 .And. nCount > 0 .And. (nPage == 1 .Or. nPage == 0)
		SOX->(dbSeek(xFilial("SOX")))
		While !SOX->(Eof()) .And. SOX->OX_FILIAL == xFilial("SOX")
			nX++
			If  nX <= nCount
				cParada := ' '
				cCronom := ' '
				cTpProg := ' '
		
				If lExisOxPar
					cParada := SOX->OX_PARADA
				EndIf

				If lExisOxCro
					cCronom := SOX->OX_CRONOM
					cTpProg := SOX->OX_TPPROG
				EndIf

     			aAdd(aSOX,{SOX->OX_FORM,SOX->OX_PRGAPON,SOX->OX_IMAGEM,SOX->OX_DESCR,cParada,cCronom,cTpProg})
			Else
				Exit
			EndIf
			SOX->(dbSkip())
		End
	Else
		If nPage > 1 //.And. (nPage * nCount) >= nRegSOX  
			nX := (((nPage - 1) * nCount) )
			SOX->(dbGoTop())
			SOX->(dbSeek(xFilial("SOX")))
			SOX->(dbSkip(nX))
			While !SOX->(Eof()) .And. SOX->OX_FILIAL == xFilial("SOX")
				If nX < (nPage * nCount) 
					cParada := ' '
					cCronom := ' '
					cTpProg := ' '
		
					If lExisOxPar
						cParada := SOX->OX_PARADA
					EndIf

					If lExisOxCro
						cCronom := SOX->OX_CRONOM
						cTpProg := SOX->OX_TPPROG
					EndIf

     				aAdd(aSOX,{SOX->OX_FORM,SOX->OX_PRGAPON,SOX->OX_IMAGEM,SOX->OX_DESCR,cParada,cCronom,cTpProg})					
					nX++
				Else
					Exit
				EndIf
				SOX->(dbSkip())
			End
		Else
			If nPage == 0 .And. nStart > 0 .And. nCount > 0 
				SOX->(dbGoTop())
				SOX->(dbSeek(xFilial("SOX")))
				SOX->(dbSkip(nStart))
				nX := nStart
				While !SOX->(Eof()) .And. SOX->OX_FILIAL == xFilial("SOX")
					If nX >= nStart .And. nX <= nCount
						cParada := ' '
						cCronom := ' '
						cTpProg := ' '
		
						If lExisOxPar
							cParada := SOX->OX_PARADA
						EndIf

						If lExisOxCro
							cCronom := SOX->OX_CRONOM
							cTpProg := SOX->OX_TPPROG
						EndIf

     					aAdd(aSOX,{SOX->OX_FORM,SOX->OX_PRGAPON,SOX->OX_IMAGEM,SOX->OX_DESCR,cParada,cCronom,cTpProg})
						nX++
					Else
						Exit
					EndIf
					SOX->(dbSkip()) 
				End  
			EndIf 
		EndIf
	EndIf
EndIf
return aSOX

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121usf

Função que consulta os formulários do usuário 

@param cUsers	  - Usuário do formulário que será consultado.
@param cGrupouser - Grupo de usuários do formulário que será consultado 

@return lRet	- Indica se o registro foi ou não excluído.

@author  Michelle Ramos Henriques
@version P12
@since   09/05/2018
/*/
//-------------------------------------------------------------------------------------------------

Function PCPA121usf(cUsers, nStart, nCount, nPage, nPrdOrd)

Local nX          := 0
Local cQuery      := ""
Local cAliasTemp  := ""
Local aSOZ        := {}
local aGrp        := {}
Local nI          := 0
Local cUsersId    := ""

Default nStart := 1
Default nCount := 20
Default nPage  := 0

SOZ->(dbSetOrder(1))

If !Empty(cUsers) 
	//Foi chamado a função PCPCodUsr duas vezes, porque essa função somente traz o usuário corretamente na segunda passagem pela função.
	//Isso só ocorre quando é chamado em api REST.
	//Foi conversado com o frame, porém desconhecem essa função.
	cUsersId := PCPCodUsr(cUsers)

	aGrp:= UsrRetGrp(cUsers)

	dbSelectArea('SOX')
	lExisOxPar := If (SOX->(ColumnPos("OX_PARADA")) >  0, .T., .F.)
	lExisOxCro := If (SOX->(ColumnPos("OX_CRONOM")) >  0, .T., .F.)

	cAliasTemp:=  GetNextAlias()

	cQuery      := "  SELECT DiSTINCT SOZ.OZ_CODFORM, SOX.OX_DESCR, SOX.OX_PRGAPON, SOX.OX_IMAGEM "

	If lExisOxPar
		cQuery      += " , SOX.OX_PARADA "
	EndIf

	If lExisOxCro
		cQuery      += " , SOX.OX_CRONOM , SOX.OX_TPPROG "
	EndIf
	
	cQuery      += "   FROM " + RetSqlName('SOX') + " SOX "
	cQuery      += "   , "    + RetSqlName('SOZ') + " SOZ "
	cQuery      += "   WHERE SOX.OX_FILIAL   = '" + xFilial("SOX") + "'"
	cQuery      += "   AND   SOZ.OZ_FILIAL   = '" + xFilial("SOZ") + "'"
	cQuery      += "   AND 	 SOX.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 SOZ.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 SOZ.OZ_CODFORM   = SOX.OX_FORM"
	
	if Len(aGrp) > 0 
		cQuery      += "   AND   (SOZ.OZ_USUARIO  = '" + cUsersId + "'"
		cQuery      += "   OR     SOZ.OZ_GRPUSU in ( "
		For nI := 1 to Len(aGrp)
			cQuery += " '"+aGrp[ni]+"' "
			if nI != Len(aGrp)
				cQuery += ","
			EndIf
		Next ni
		cQuery		   += ")) "
	else
		cQuery      += "   AND   SOZ.OZ_USUARIO  = '" + cUsersId + "'"
	EndIf

	If nPrdOrd == 1
		cQuery += " AND SOX.OX_PRGAPON = '6' "
	Else
		cQuery += " AND SOX.OX_PRGAPON <> '6' "
	EndIf

	cQuery    := ChangeQuery(cQuery)
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

	If nStart == 1 .And. nCount > 0 .And. (nPage == 1 .Or. nPage == 0)
		While !(cAliasTemp)->(Eof()) 
			nX++
			If  nX <= nCount

				cParada := ' '
				cCronom := ' '
				cTpProg := ' '
		
				If lExisOxPar
					cParada := (cAliasTemp)->OX_PARADA
				EndIf

				If lExisOxCro
					cCronom := (cAliasTemp)->OX_CRONOM
					cTpProg := (cAliasTemp)->OX_TPPROG
				EndIf

				aAdd(aSOZ,{(cAliasTemp)->OZ_CODFORM, (cAliasTemp)->OX_DESCR, (cAliasTemp)->OX_PRGAPON, (cAliasTemp)->OX_IMAGEM,cParada,cCronom,cTpProg})				
			Else
				Exit
			EndIf
			(cAliasTemp)->(dbSkip())
		End
	Else
		If nPage > 1 
			nX := (((nPage - 1) * nCount) )
			(cAliasTemp)->(dbGoTop())
			(cAliasTemp)->(dbSkip(nX))
			While !(cAliasTemp)->(Eof()) 
				If nX < (nPage * nCount) 
					
					cParada := ' '
					cCronom := ' '
					cTpProg := ' '

					If lExisOxPar
						cParada := (cAliasTemp)->OX_PARADA
					EndIf

					If lExisOxCro
						cCronom := (cAliasTemp)->OX_CRONOM
						cTpProg := (cAliasTemp)->OX_TPPROG
					EndIf

					aAdd(aSOZ,{(cAliasTemp)->OZ_CODFORM, (cAliasTemp)->OX_DESCR, (cAliasTemp)->OX_PRGAPON, (cAliasTemp)->OX_IMAGEM,cParada,cCronom,cTpProg})									
					nX++
				Else
					Exit
				EndIf
				(cAliasTemp)->(dbSkip())
			End
		Else
			If nPage == 0 .And. nStart > 0 .And. nCount > 0 
				(cAliasTemp)->(dbGoTop())
				(cAliasTemp)->(dbSkip(nStart))
				nX := nStart
				While !(cAliasTemp)->(Eof()) 
					If nX >= nStart .And. nX <= nCount

						cParada := ' '
						cCronom := ' '
						cTpProg := ' '

						If lExisOxPar
							cParada := (cAliasTemp)->OX_PARADA
						EndIf

						If lExisOxCro
							cCronom := (cAliasTemp)->OX_CRONOM
							cTpProg := (cAliasTemp)->OX_TPPROG
						EndIf

						aAdd(aSOZ,{(cAliasTemp)->OZ_CODFORM, (cAliasTemp)->OX_DESCR, (cAliasTemp)->OX_PRGAPON, (cAliasTemp)->OX_IMAGEM,cParada,cCronom,cTpProg})															
						nX++
					Else
						Exit
					EndIf
					(cAliasTemp)->(dbSkip()) 
				End  
			EndIf 
		EndIf
	EndIf
EndIf

(cAliasTemp)->(DBCloseArea())

return aSOZ

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121fld

Função que consulta os campos do formulários do usuário 

@param cUsers	  - Usuário do formulário que será consultado.
@param cGrupouser - Grupo de usuários do formulário que será consultado 

@return lRet	- Indica se o registro foi ou não excluído.

@author  Michelle Ramos Henriques
@version P12
@since   09/05/2018
/*/
//-------------------------------------------------------------------------------------------------

Function PCPA121fld(cCode, cUsers, nStart, nCount, nPage)

Local nX          := 0
Local cQuery      := ""
Local cAliasTemp  := ""
Local aSOY        := {}
local aGrp        := {}
Local nI          := 0
Local cUsersId    := ""

Default nStart := 1
Default nCount := 20
Default nPage  := 0


SOY->(dbSetOrder(1))

If !Empty(cCode) .And. !Empty(cUsers)
	cCode := PadR(cCode, TamSX3("OY_CODFORM")[1])
	//Foi chamado a função PCPCodUsr duas vezes, porque essa função somente traz o usuário corretamente na segunda passagem pela função.
	//Isso só ocorre quando é chamado em api REST.
	//Foi conversado com o frame, porém desconhecem essa função.
	cUsersId := PCPCodUsr(cUsers)

	aGrp:= UsrRetGrp(cUsers)

	cAliasTemp:=  GetNextAlias()
	cQuery      := "  SELECT DISTINCT SOY.OY_CODFORM, SOY.OY_CAMPO, SOY.OY_DESCAMP, SOY.OY_CODBAR, SOY.OY_VISIVEL, SOY.OY_EDITA, SOY.OY_VALPAD  "
	cQuery      += "   FROM " + RetSqlName('SOY') + " SOY "
	cQuery      += "   , "    + RetSqlName('SOZ') + " SOZ "
	cQuery      += "   WHERE SOY.OY_FILIAL   = '" + xFilial("SOX") + "'"
	cQuery      += "   AND   SOZ.OZ_FILIAL   = '" + xFilial("SOZ") + "'"
	cQuery      += "   AND 	 SOY.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 SOZ.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 SOY.OY_CODFORM = SOZ.OZ_CODFORM"
	cQuery      += "   AND 	 SOY.OY_CODFORM  = '" + cCode + "'"
	
	if Len(aGrp) > 0 
		cQuery      += "   AND   (SOZ.OZ_USUARIO  = '" + cUsersId + "'"
		cQuery      += "   OR     SOZ.OZ_GRPUSU in ( "
		For nI := 1 to Len(aGrp)
			cQuery += " '"+aGrp[ni]+"' "
			if nI != Len(aGrp)
				cQuery += ","
			EndIf
		Next ni
		cQuery		   += ")) "
	else
		cQuery      += "   AND   SOZ.OZ_USUARIO  = '" + cUsersId + "'"
	EndIf
	
	cQuery    := ChangeQuery(cQuery)
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)


	If nStart == 1 .And. nCount > 0 .And. (nPage == 1 .Or. nPage == 0)
		While !(cAliasTemp)->(Eof()) 
			nX++
			If  nX <= nCount
				aAdd(aSOY,{(cAliasTemp)->OY_CODFORM, (cAliasTemp)->OY_CAMPO, (cAliasTemp)->OY_DESCAMP, (cAliasTemp)->OY_CODBAR, (cAliasTemp)->OY_VISIVEL, (cAliasTemp)->OY_EDITA, (cAliasTemp)->OY_VALPAD})
			Else
				Exit
			EndIf
			(cAliasTemp)->(dbSkip())
		End
	Else
		If nPage > 1 
			nX := (((nPage - 1) * nCount) )
			(cAliasTemp)->(dbGoTop())
			(cAliasTemp)->(dbSkip(nX))
			While !(cAliasTemp)->(Eof()) 
				If nX < (nPage * nCount) 
					aAdd(aSOY,{(cAliasTemp)->OY_CODFORM, (cAliasTemp)->OY_CAMPO, (cAliasTemp)->OY_DESCAMP, (cAliasTemp)->OY_CODBAR, (cAliasTemp)->OY_VISIVEL, (cAliasTemp)->OY_EDITA, (cAliasTemp)->OY_VALPAD})
					nX++
				Else
					Exit
				EndIf
				(cAliasTemp)->(dbSkip())
			End
		Else
			If nPage == 0 .And. nStart > 0 .And. nCount > 0 
				(cAliasTemp)->(dbGoTop())
				(cAliasTemp)->(dbSkip(nStart))
				nX := nStart
				While !(cAliasTemp)->(Eof()) 
					If nX >= nStart .And. nX <= nCount
						aAdd(aSOY,{(cAliasTemp)->OY_CODFORM, (cAliasTemp)->OY_CAMPO, (cAliasTemp)->OY_DESCAMP, (cAliasTemp)->OY_CODBAR, (cAliasTemp)->OY_VISIVEL, (cAliasTemp)->OY_EDITA, (cAliasTemp)->OY_VALPAD})
						nX++
					Else
						Exit
					EndIf
					(cAliasTemp)->(dbSkip()) 
				End  
			EndIf 
		EndIf
	EndIf
EndIf

(cAliasTemp)->(DBCloseArea())

return aSOY

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121maq

Função que consulta as máquinas habilitadas para o formulários do usuário 

@param cCodForm	  - Código do formulário.
@param cUsers	  - Usuário do formulário que será consultado.

@return aHWS	- Máquinas habilitadas para o formulário.

@author  Parffit Jim Balsanelli
@version P12
@since   27/05/2020
/*/
//-------------------------------------------------------------------------------------------------

Function PCPA121maq(cCodForm, cUsers, nStart, nCount, nPage)

Local nX          := 0
Local cQuery      := ""
Local cAliasTemp  := ""
Local aHWS        := {}
local aGrp        := {}
Local nI          := 0
Local cUsersId    := ""

Default nStart := 1
Default nCount := 20
Default nPage  := 0

If !AliasInDic("HWS")
	return aHWS
EndIf

HWS->(dbSetOrder(1))

If !Empty(cCodForm) .And. !Empty(cUsers)
	cCodForm := PadR(cCodForm, TamSX3("HWS_FORM")[1])
	//Foi chamado a função PCPCodUsr duas vezes, porque essa função somente traz o usuário corretamente na segunda passagem pela função.
	//Isso só ocorre quando é chamado em api REST.
	//Foi conversado com o frame, porém desconhecem essa função.
	cUsersId := PCPCodUsr(cUsers)
 
	
	aGrp:= UsrRetGrp(cUsers)

	cAliasTemp:=  GetNextAlias()
	cQuery      := "  SELECT DISTINCT HWS.HWS_FORM, HWS.HWS_CDMQ, CYB.CYB_DSMQ  "
	cQuery      += "   FROM " + RetSqlName('HWS') + " HWS "
	cQuery      += "   , "    + RetSqlName('CYB') + " CYB "
	cQuery      += "   , "    + RetSqlName('SOZ') + " SOZ "
	cQuery      += "   WHERE HWS.HWS_FILIAL  = '" + xFilial("SOX") + "'"
	cQuery      += "   AND   SOZ.OZ_FILIAL   = '" + xFilial("SOZ") + "'"
	cQuery      += "   AND   CYB.CYB_FILIAL  = '" + xFilial("CYB") + "'"
	cQuery      += "   AND 	 HWS.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 SOZ.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 CYB.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 HWS.HWS_FORM = SOZ.OZ_CODFORM"
	cQuery      += "   AND 	 HWS.HWS_FORM  = '" + cCodForm + "'"
	cQuery      += "   AND 	 CYB.CYB_CDMQ = HWS.HWS_CDMQ"
	
	if Len(aGrp) > 0 
		cQuery      += "   AND   (SOZ.OZ_USUARIO  = '" + cUsersId + "'"
		cQuery      += "   OR     SOZ.OZ_GRPUSU in ( "
		For nI := 1 to Len(aGrp)
			cQuery += " '"+aGrp[ni]+"' "
			if nI != Len(aGrp)
				cQuery += ","
			EndIf
		Next ni
		cQuery		   += ")) "
	else
		cQuery      += "   AND   SOZ.OZ_USUARIO  = '" + cUsersId + "'"
	EndIf

	cQuery      += " ORDER BY HWS.HWS_FORM, HWS.HWS_CDMQ"

	cQuery    := ChangeQuery(cQuery)
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)


	If nStart == 1 .And. nCount > 0 .And. (nPage == 1 .Or. nPage == 0)
		While !(cAliasTemp)->(Eof()) 
			nX++
			If  nX <= nCount
				aAdd(aHWS,{(cAliasTemp)->HWS_FORM, (cAliasTemp)->HWS_CDMQ, (cAliasTemp)->CYB_DSMQ})
			Else
				Exit
			EndIf
			(cAliasTemp)->(dbSkip())
		End
	Else
		If nPage > 1 
			nX := (((nPage - 1) * nCount) )
			(cAliasTemp)->(dbGoTop())
			(cAliasTemp)->(dbSkip(nX))
			While !(cAliasTemp)->(Eof()) 
				If nX < (nPage * nCount) 
 				    aAdd(aHWS,{(cAliasTemp)->HWS_FORM, (cAliasTemp)->HWS_CDMQ, (cAliasTemp)->CYB_DSMQ})
					nX++
				Else
					Exit
				EndIf
				(cAliasTemp)->(dbSkip())
			End
		Else
			If nPage == 0 .And. nStart > 0 .And. nCount > 0 
				(cAliasTemp)->(dbGoTop())
				(cAliasTemp)->(dbSkip(nStart))
				nX := nStart
				While !(cAliasTemp)->(Eof()) 
					If nX >= nStart .And. nX <= nCount
 				        aAdd(aHWS,{(cAliasTemp)->HWS_FORM, (cAliasTemp)->HWS_CDMQ, (cAliasTemp)->CYB_DSMQ})
						nX++
					Else
						Exit
					EndIf
					(cAliasTemp)->(dbSkip()) 
				End  
			EndIf 
		EndIf
	EndIf
EndIf

(cAliasTemp)->(DBCloseArea())

return aHWS

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA121cus

Função que consulta os campos customizados para o formulário do usuário 

@param cCodForm	  - Código do formulário.
@param cUsers	  - Usuário do formulário que será consultado.

@return aSMC	- Campos customizados.

@author  Michele Girardi
@version P12
@since   20/10/2020
/*/
//-------------------------------------------------------------------------------------------------

Function PCPA121cus(cCodForm, cUsers, nStart, nCount, nPage)

Local nX          := 0
Local cQuery      := ""
Local cAliasTemp  := ""
Local aSMC        := {}
local aGrp        := {}
Local nI          := 0
Local cUsersId    := ""

Default nStart := 1
Default nCount := 20
Default nPage  := 0

If !AliasInDic("SMC")
	return aSMC
EndIf

SMC->(dbSetOrder(1))

If !Empty(cCodForm) .And. !Empty(cUsers)
	cCodForm := PadR(cCodForm, TamSX3("MC_CODFORM")[1])
	//Foi chamado a função PCPCodUsr duas vezes, porque essa função somente traz o usuário corretamente na segunda passagem pela função.
	//Isso só ocorre quando é chamado em api REST.
	//Foi conversado com o frame, porém desconhecem essa função.
	cUsersId := PCPCodUsr(cUsers)

	aGrp:= UsrRetGrp(cUsers)

	cAliasTemp:=  GetNextAlias()
	cQuery      := "  SELECT DISTINCT SMC.MC_CODFORM, SMC.MC_TIPO, SMC.MC_CAMPO, SMC.MC_DESCAMP, SMC.MC_CODBAR, SMC.MC_VISIVEL, SMC.MC_EDITA, SMC.MC_VALPAD "
	If SMC->(FieldPos("MC_TABELA")) > 0
		cQuery += " , SMC.MC_TABELA  "
	else
		cQuery += " , ' ' AS MC_TABELA "
	EndIf
	
	cQuery      += "   FROM " + RetSqlName('SMC') + " SMC "
	cQuery      += "   , "    + RetSqlName('SOZ') + " SOZ "
	cQuery      += "   WHERE SMC.MC_FILIAL   = '" + xFilial("SMC") + "'"
	cQuery      += "   AND   SOZ.OZ_FILIAL   = '" + xFilial("SOZ") + "'"
	cQuery      += "   AND 	 SMC.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 SOZ.D_E_L_E_T_  = ' '"
	cQuery      += "   AND 	 SMC.MC_CODFORM  = SOZ.OZ_CODFORM"
	cQuery      += "   AND 	 SMC.MC_CODFORM  = '" + cCodForm + "'"
	
	if Len(aGrp) > 0 
		cQuery      += "   AND   (SOZ.OZ_USUARIO  = '" + cUsersId + "'"
		cQuery      += "   OR     SOZ.OZ_GRPUSU in ( "
		For nI := 1 to Len(aGrp)
			cQuery += " '"+aGrp[ni]+"' "
			if nI != Len(aGrp)
				cQuery += ","
			EndIf
		Next ni
		cQuery		   += ")) "
	else
		cQuery      += "   AND   SOZ.OZ_USUARIO  = '" + cUsersId + "'"
	EndIf

	cQuery    := ChangeQuery(cQuery)
	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)


	If nStart == 1 .And. nCount > 0 .And. (nPage == 1 .Or. nPage == 0)
		While !(cAliasTemp)->(Eof()) 
			nX++
			If  nX <= nCount
				aAdd(aSMC,{(cAliasTemp)->MC_CODFORM, (cAliasTemp)->MC_TIPO,   (cAliasTemp)->MC_CAMPO,   ;
				           (cAliasTemp)->MC_DESCAMP, (cAliasTemp)->MC_CODBAR, (cAliasTemp)->MC_VISIVEL, ;
						   (cAliasTemp)->MC_EDITA,   (cAliasTemp)->MC_VALPAD, (cAliasTemp)->MC_TABELA })
			Else
				Exit
			EndIf
			(cAliasTemp)->(dbSkip())
		End
	Else
		If nPage > 1 
			nX := (((nPage - 1) * nCount) )
			(cAliasTemp)->(dbGoTop())
			(cAliasTemp)->(dbSkip(nX))
			While !(cAliasTemp)->(Eof()) 
				If nX < (nPage * nCount) 
 				    aAdd(aSMC,{(cAliasTemp)->MC_CODFORM, (cAliasTemp)->MC_TIPO,   (cAliasTemp)->MC_CAMPO,   ;
				           	   (cAliasTemp)->MC_DESCAMP, (cAliasTemp)->MC_CODBAR, (cAliasTemp)->MC_VISIVEL, ;
							   (cAliasTemp)->MC_EDITA,   (cAliasTemp)->MC_VALPAD, (cAliasTemp)->MC_TABELA })
					nX++
				Else
					Exit
				EndIf
				(cAliasTemp)->(dbSkip())
			End
		Else
			If nPage == 0 .And. nStart > 0 .And. nCount > 0 
				(cAliasTemp)->(dbGoTop())
				(cAliasTemp)->(dbSkip(nStart))
				nX := nStart
				While !(cAliasTemp)->(Eof()) 
					If nX >= nStart .And. nX <= nCount
 				        aAdd(aSMC,{(cAliasTemp)->MC_CODFORM, (cAliasTemp)->MC_TIPO,   (cAliasTemp)->MC_CAMPO,   ;
				                   (cAliasTemp)->MC_DESCAMP, (cAliasTemp)->MC_CODBAR, (cAliasTemp)->MC_VISIVEL, ;
						           (cAliasTemp)->MC_EDITA,   (cAliasTemp)->MC_VALPAD, (cAliasTemp)->MC_TABELA })
						nX++
					Else
						Exit
					EndIf
					(cAliasTemp)->(dbSkip()) 
				End  
			EndIf 
		EndIf
	EndIf
EndIf

(cAliasTemp)->(DBCloseArea())

return aSMC

/*/{Protheus.doc} PCPA121RCC
	Retorna valor do campo customizado
	
	@author Michele Girardi
	@since 20/10/2020
	@param Sem parâmetro
	@return Valor do Campo

	/*/

Function PCPA121RCC(cForm, cTipo)

Local cQuery      := ""
Local cAliasTemp  := ""
Local cCampo      := " "

If !AliasInDic("SMC")
	return cCampo
EndIf

cAliasTemp:=  GetNextAlias()

	cQuery      := "  SELECT SMC.MC_CAMPO "
	cQuery      += "   FROM " + RetSqlName('SMC') + " SMC "
	cQuery      += "   WHERE SMC.MC_FILIAL   = '" + xFilial("SMC") + "'"
	cQuery      += "   AND 	 SMC.D_E_L_E_T_  = ' ' "
	cQuery      += "   AND 	 SMC.MC_CODFORM  = '" + cForm + "'"
	cQuery      += "   AND 	 SMC.MC_TIPO     = '" + cTipo + "'"
	cQuery    := ChangeQuery(cQuery)

	dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

	While !(cAliasTemp)->(Eof()) 

		cCampo := (cAliasTemp)->MC_CAMPO
		Exit

	End

(cAliasTemp)->(DBCloseArea())

Return cCampo

/*/{Protheus.doc} PCPA121Emp
Faz a busca das informações do formulário de empenhos.

@type  Function
@author lucas.franca
@since 04/03/2021
@version P12
@param cCodForm  , Character, Código do formulário para busca
@param lRetFields, Logic    , Indica se deve retornar os campos do empenho.
@return oSMJ, Object, JSONObject com os dados do formulário de empenhos
/*/
Function PCPA121Emp(cCodForm, lRetFields)
	Local cChave := ""
	Local nPos   := 0
	Local oSMJ   := JsonObject():New()

	//Valores padrão.
	oSMJ["viewAllocations"  ] := "2"
	oSMJ["insertAllocations"] := "2"
	oSMJ["updateAllocations"] := "2"
	oSMJ["deleteAllocations"] := "2"
	If lRetFields
		oSMJ["allocationFields" ] := {}
	EndIf

	//Busca na tabela SMJ
	SMJ->(dbSetOrder(1))
	
	cCodForm := PadR(cCodForm, GetSX3Cache("MJ_CODFORM", "X3_TAMANHO"))
	cChave   := xFilial("SMJ") + cCodForm

	If SMJ->(dbSeek(cChave))
		oSMJ["viewAllocations"  ] := SMJ->MJ_VISUAL
		oSMJ["insertAllocations"] := SMJ->MJ_INCLUI
		oSMJ["updateAllocations"] := SMJ->MJ_ALTERA
		oSMJ["deleteAllocations"] := SMJ->MJ_EXCLUI

		If lRetFields
			While SMJ->(MJ_FILIAL+MJ_CODFORM) == cChave

				nPos++
				aAdd(oSMJ["allocationFields"], JsonObject():New())

				oSMJ["allocationFields"][nPos]["code"       ] := EncodeUTF8(SMJ->MJ_CODFORM)
				oSMJ["allocationFields"][nPos]["field"      ] := trim(SMJ->MJ_CAMPO)
				oSMJ["allocationFields"][nPos]["description"] := trim(EncodeUTF8(SMJ->MJ_DESCAMP))
				oSMJ["allocationFields"][nPos]["codebar"    ] := SMJ->MJ_CODBAR
				oSMJ["allocationFields"][nPos]["visible"    ] := SMJ->MJ_VISIVEL
				oSMJ["allocationFields"][nPos]["editable"   ] := SMJ->MJ_EDITA
				oSMJ["allocationFields"][nPos]["default"    ] := execPad(trim(SMJ->MJ_VALPAD))

				SMJ->(dbSkip())
			End
		EndIf
	EndIf

Return oSMJ
