#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "FINA842.CH"

/*/{Protheus.doc} FINA842
Migração dos registros para os novos cabeçalhos da OP e Recibo.
@author William Matos Gundim Junior
@since 19/11/2014	
@version 12
/*/
/*
Luis Enríquez 30/12/2016 SERINN001-231 Se realizó merge para agregar cambió de creación de tablas
									   temp. realizado para ctree, usando clase FWTemporaryTable 
*/
Function FINA842()
	Local oWizard   	:= Nil
	Local oProcesso 	:= Nil
	//	Local bProcess  	:= {|oProcesso| Fn842Migra(oProcesso) }
	Local aInfo     	:= {}

	Private aSelFil 	:= {}
	Private aLstSM0		:= {}
	Private aLstFil		:= {}
	Private lOP 		:= .F.
	Private lRC 		:= .F.
	Private cArqTrab	:= ""
	Private dDataIni	:= CtoD("01/09/94","DDMMYY")
	Private dDataFim 	:= Date()
	Private oTmpTable := Nil
	Private bProcess  	:= {|oProcesso| Fn842Migra(oProcesso) }
	aLstSM0 := FWLoadSM0()

	Aadd(aInfo,{STR0001,{|oProcesso|FnCriaPainel(oProcesso) },"INSTRUME" })

	oProcesso := tNewProcess():New("FINA842",;
	STR0002,; //
	bProcess,;
	STR0003,;
	/*"cPergunte"*/,;
	aInfo)
	Asize(aSelFil,0)
	Asize(aLstFil,0)
	Asize(aLstSM0,0)
	aSelFil := Nil
	aLstFil := Nil
	aLstSM0 := Nil
Return

/*/{Protheus.doc} FnCriaPainel
Cria painel para selecionar as configurações de migação dos registros para a FJR/FJT.
@author William Matos Gundim Junior
@since 19/11/2014	
@version 12
/*/
Function FnCriaPainel(oPanel)
	Local oMrkBrowse	:= Nil
	Local oChkOP 		:= Nil
	Local oChkRC 		:= Nil
	Local oButton		:= Nil
	Local oDataIni 		:= Nil
	Local oDataFim 		:= Nil
	Local oSize			:= Nil
	Local oBrwFil		:= Nil

	//Tipos
	TSay():New(010,028,{||STR0004},oPanel,,,,,,.T.)
	oChkOP   := TCheckBox():New(10,100,STR0005,{|l|lOP := If(PCount()>0, lOP := l, lOP)},oPanel,100,210,,,,,,,,.T.,,,)
	oChkRC   := TCheckBox():New(20,100,STR0006,{|u|lRC := If(PCount()>0, lRC := u, lRC)},oPanel,100,210,,,,,,,,.T.,,,)

	//Data Inicial
	TSay():New(035,028,{||STR0009},oPanel,,,,,,.T.)
	oDataIni := TGET():Create(oPanel)
	oDataIni:cName 				:= "oDataIni"
	oDataIni:nWidth 			:= 100
	oDataIni:nHeight 			:= 21
	oDataIni:nLeft 				:= 140
	oDataIni:nTop 				:= 070
	oDataIni:lShowHint			:= .F.
	oDataIni:Align 				:= 0
	oDataIni:cVariable 			:= "dDataIni"
	oDataIni:bSetGet 			:={|u| If(PCount()>0,dDataIni:=u,dDataIni) }
	oDataIni:lPassword		 	:= .F.
	oDataIni:Picture 			:= "@D"
	oDataIni:lHasButton 		:= .T.
	oDataIni:bWhen 				:= {|| .T.}
	oDataIni:lVisibleControl 	:= .T.
	oDataIni:Refresh()

	//Data Final.
	TSay():New(055,028,{||STR0010},oPanel,,,,,,.T.)
	oDataFim := TGET():Create(oPanel)
	oDataFim:cName 				:= "oDataFim"
	oDataFim:nWidth 			:= 100
	oDataFim:nHeight 			:= 21
	oDataFim:nLeft 				:= 140
	oDataFim:nTop 				:= 110
	oDataFim:lShowHint			:= .F.
	oDataFim:Align 				:= 0
	oDataFim:cVariable 			:= "dDataFim"
	oDataFim:bSetGet 			:= {|u| If(PCount()>0,dDataFim:=u,dDataFim) }
	oDataFim:lPassword		 	:= .F.
	oDataFim:Picture 			:= "@D"
	oDataFim:lHasButton 		:= .T.
	oDataFim:bWhen 				:= {|| .T.}
	oDataFim:lVisibleControl 	:= .T.
	oDataFim:Refresh()

	//Filiais podem ser selecionadas apenas se as tabelas não estiverem totalmente compartilhadas.
	If 	!(FWModeAccess("SEL",1) == "C" .AND. FWModeAccess("SEL",2) == "C" .AND. FWModeAccess("SEL",3) == "C" .AND.;
	FWModeAccess("SEK",1) == "C" .AND. FWModeAccess("SEK",2) == "C" .AND. FWModeAccess("SEK",3) == "C") 
		/*
		Selecão de filiais */ 
		oButton  := TButton():New( 75, 28, STR0007,oPanel,{|| FN842Filiais(oBrwFil)}, 100,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	EndIf

	oBrwFil := TCBrowse():New(100,28,100,100,,,,oPanel,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)
	oBrwFil:AddColumn(TCColumn():New(SN3->(RetTitle("N3_FILIAL")),{|| aLstFil[oBrwFil:nAt,1]},,,,"LEFT",20,.F.,.F.,,,,,))
	oBrwFil:AddColumn(TCColumn():New(" ",{|| aLstFil[oBrwFil:nAt,2]},,,,"LEFT",25,.F.,.F.,,,,,))
	oBrwFil:nHeight :=  oPanel:nHeight/2
	oBrwFil:nWidth :=  oPanel:nWidth * 0.8
	oBrwFil:lAutoEdit := .F.
	oBrwFil:lReadOnly := .F.
	oBrwFil:SetArray(aLstFil)
	oBrwFil:lVisible := .F.
	oBrwFil:Refresh()
Return()


/*/{Protheus.doc} Fn842Migra
Migração dos dados para a tabela FJR - Cabeçalho OP.
@author William Matos Gundim Junior
@since 19/11/2014	
@version 12
/*/
Function Fn842Migra(oSelf)
	Local oModel	:= FWLoadModel('FINA842')
	Local oSubFJR 	:= oModel:GetModel('FJRDETAIL')
	Local oSubFJT 	:= oModel:GetModel('FJTDETAIL')
	Local cQuery 	:= ''
	Local cAliasOP	:= ''
	Local cAliasRC	:= ''
	Local cLog		:= ''
	Local cFilOri	:= cFilAnt
	Local cTmpFil	:= ""
	Local aTmpFil	:= {}
	Local nX		:= 0
	Local cVersao	:= ""

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	If lOP

		//
		oSelf:IncRegua1(STR0011)
		oSelf:SetRegua1(1)
		oSelf:SetRegua2(SEK->(RecCount()))

		//Ordens de Pagamento.
		cAliasOP := GetNextAlias()

		cQuery += " SELECT DISTINCT EK_FILIAL, EK_ORDPAGO, EK_EMISSAO, EK_NATUREZ, EK_FORNEPG, EK_LOJAPG, EK_CANCEL, "
		cQuery += " EK_PGTOELT, EK_DOCREC "
		cQuery += " FROM "  + RetSQLName("SEK")	+ " SEK"	
		cQuery += " WHERE "

		If !Empty(aSelFil)
			cQuery += " SEK.EK_FILIAL " + GetRngFil(aSelFil,"SEK",.T.,@cTmpFil) + " AND "
			Aadd(aTmpFil,cTmpFil)
		Else
			cQuery += " SEK.EK_FILIAL = '" + xFilial("SEK") + "' AND "
		EndIf

		//Data
		cQuery += " SEK.EK_EMISSAO BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' AND "
		//
		cQuery += " SEK.EK_FILIAL || SEK.EK_ORDPAGO NOT IN( "
		cQuery +=									 " SELECT FJR_FILIAL || FJR_ORDPAG FROM " + RetSQLName("FJR")		
		cQuery +=									 " WHERE D_E_L_E_T_ = '' )
		cQuery += " ORDER BY EK_ORDPAGO"			

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOP,.T.,.T.)
		dbSelectArea(cAliasOP)
		DbGotop()

		While !(cAliasOP)->(Eof())

			//
			oSelf:IncRegua2(STR0012 + cValToChar((cAliasOP)->(Recno())))
			oSelf:SetRegua2((cAliasOP)->(Recno()))

			//Caso tenha adicionado algum registro e a filial do proximo registro é diferente, os dados são gravados.
			If oModel:GetModel('FJRDETAIL'):IsModified() .AND. cFilAnt <> (cAliasOP)->EK_FILIAL
				Fn842Commit()		
			EndIf 

			If !oSubFJR:IsEmpty() 
				oSubFJR:AddLine()
			EndIf

			//Existem N mas na FJR é necessario apenas um registro.
			If !oSubFJR:SeekLine({{"FJR_FILIAL",(cAliasOP)->EK_FILIAL },{"FJR_ORDPAG", (cAliasOP)->EK_ORDPAGO}})

				cFilAnt := (cAliasOP)->EK_FILIAL
				oSubFJR:SetValue('FJR_ORDPAG'	, (cAliasOP)->EK_ORDPAGO )
				oSubFJR:SetValue('FJR_EMISSA'	, StoD((cAliasOP)->EK_EMISSAO ))	
				oSubFJR:SetValue('FJR_NATURE'	, (cAliasOP)->EK_NATUREZ )
				oSubFJR:SetValue('FJR_FORNEC'	, (cAliasOP)->EK_FORNEPG )
				oSubFJR:LoadValue('FJR_LOJA'	, (cAliasOP)->EK_LOJAPG )
				oSubFJR:SetValue('FJR_CANCEL'	, If((cAliasOP)->EK_CANCEL == "F", .F. , .T.)	)
				oSubFJR:SetValue('FJR_PGTELT'	, (cAliasOP)->EK_PGTOELT	)
				oSubFJR:SetValue('FJR_DOCREC'	, (cAliasOP)->EK_DOCREC )

			EndIf	

			(cAliasOP)->(dbSkip())

		EndDo

		DbSelectArea(cAliasOP)
		DbCloseArea()
		cQuery := ''	
	EndIf	

	//Recibos de Cobrança
	If lRC

		//
		oSelf:IncRegua1(STR0013)
		oSelf:SetRegua1(2)
		oSelf:SetRegua2(SEL->(RecCount()))

		cAliasRC := GetNextAlias()
		cQuery   := " SELECT EL_FILIAL, EL_DTDIGIT, EL_SERIE, EL_RECIBO, EL_VERSAO, EL_EMISSAO, EL_NATUREZ, EL_CLIENTE, EL_LOJA, "
		cQuery   += " EL_COBRAD, EL_RECPROV, EL_CANCEL"
		cQuery	 += " FROM " + RetSQLName("SEL")
		cQuery   += " WHERE " 
		//Filiais selecionadas.

		If !Empty(aSelFil)
			cQuery += " EL_FILIAL " + GetRngFil(aSelFil,"SEL",.T.,@cTmpFil) + " AND "
			Aadd(aTmpFil,cTmpFil)
		Else
			cQuery += " EL_FILIAL = '" + xFilial("SEL") + "' AND "
		EndIf
		//Data
		cQuery += " EL_EMISSAO BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' AND "
		//
		cQuery += " D_E_L_E_T_ = '' "
		cQuery += " ORDER BY EL_FILIAL, EL_SERIE, EL_RECIBO, EL_VERSAO"	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRC,.T.,.T.)
		dbSelectArea(cAliasRC)
		DbGotop()

		dbSelectArea('FJT')
		FJT->(dbSetOrder(1)) // FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO

		While !(cAliasRC)->(Eof())

			oSelf:IncRegua2(STR0012 + cValToChar((cAliasRC)->(Recno())))
			//Busca pelo registro na FJT, caso exista ele não será exportado.
			If !FJT->(dbSeek( (cAliasRC)->EL_FILIAL + (cAliasRC)->EL_SERIE + (cAliasRC)->EL_RECIBO + (cAliasRC)->EL_VERSAO))

				If !oSubFJT:SeekLine({{"FJT_SERIE",(cAliasRC)->EL_SERIE},{"FJT_RECIBO",(cAliasRC)->EL_RECIBO}})

					//Caso tenha adicionado algum registro e a filial do proximo registro é diferente, os dados são gravados.
					If (oModel:GetModel('FJTDETAIL'):IsModified() .OR. oModel:GetModel('FJRDETAIL'):IsModified()) .AND. cFilAnt <> (cAliasRC)->EL_FILIAL
						Fn842Commit()
					EndIf

					If !oSubFJT:IsEmpty() 
						oSubFJT:AddLine()
					EndIf	

					cFilAnt := (cAliasRC)->EL_FILIAL
					oSubFJT:SetValue('FJT_DTDIGI'	, StoD((cAliasRC)->EL_DTDIGIT))	
					oSubFJT:SetValue('FJT_SERIE'	, (cAliasRC)->EL_SERIE)
					oSubFJT:SetValue('FJT_RECIBO'	, (cAliasRC)->EL_RECIBO )
					oSubFJT:SetValue('FJT_VERSAO'	, (cAliasRC)->EL_VERSAO)
					oSubFJT:SetValue('FJT_EMISSA'	, StoD((cAliasRC)->EL_EMISSAO))
					oSubFJT:SetValue('FJT_NATURE'	, (cAliasRC)->EL_NATUREZ	)
					oSubFJT:SetValue('FJT_CLIENT'	, (cAliasRC)->EL_CLIENTE )
					oSubFJT:SetValue('FJT_LOJA'		, (cAliasRC)->EL_LOJA )
					oSubFJT:SetValue('FJT_COBRAD'	, (cAliasRC)->EL_COBRAD )
					oSubFJT:SetValue('FJT_RECPRV'	, (cAliasRC)->EL_RECPROV )
					oSubFJT:SetValue('FJT_CANCEL'	, (cAliasRC)->EL_CANCEL )
					oSubFJT:SetValue('FJT_VERATU'	, '1' )

				EndIf

			EndIf

			(cAliasRC)->(dbSkip())	

		EndDo

		DbSelectArea(cAliasRC)
		DbCloseArea()	

	EndIf	

	Fn842Commit() //Grava os dados.

	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	EndIf
	cFilAnt := cFilOri

	If !Empty(aTmpFil)
		For nX := 1 To Len(aTmpFil)
			CtbTmpErase(aTmpFil[nX])
		Next
	Endif

Return 


/*/{Protheus.doc} ModelDef
Modelo de dados para as tabelas FJR/FJT.
@author William Matos Gundim Junior
@since 19/11/2014	
@version 12
/*/
Function ModelDef()
	Local oModel 	 := MPFormModel():New('FINA842')
	Local oStruFJR := FWFormStruct(1, 'FJR')
	Local oStruFJT := FWFormStruct(1, 'FJT')
	Local cArqTrab  := ''
	Local oField	:= FWFormModelStruct():New()
	Local aStru		:= {}

	Aadd(aStru, {"FJR_CAMPO","C",1,0})
	cArqTrab := CriaTrab(aStru,.f.) // Nome do arquivo temporario
	oTmpTable := FWTemporaryTable():New(cArqTrab)
	oTmpTable:SetFields( aStru ) //MC	
	oTmpTable:AddIndex("IN2", {"FJR_CAMPO"}) //LEEM
	oTmpTable:Create()

	//Criado falso field, para alimentar a FJ0 de uma unica vez pelo Detail
	oField:AddTable(cArqTrab,,'__ARQFJR')
	oField:AddField("Id","","FJR_CAMPO","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)
	//
	oModel:AddFields('FJRMASTER', /*cOwner*/, oField , , ,{|o|{}} )

	oModel:AddGrid('FJRDETAIL','FJRMASTER',oStruFJR)
	oModel:GetModel('FJRDETAIL' ):SetOptional( .T. )
	oModel:AddGrid('FJTDETAIL','FJRMASTER',oStruFJT)
	oModel:GetModel('FJTDETAIL' ):SetOptional( .T. )
	oModel:SetActivate( {|oModel| Fn842Load(oModel) } )

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} Fn842Load
Função de ativação do modelo de dados.
@author William Matos Gundim Junior
@since 19/11/2014	
@version 12
/*/
Function Fn842Load(oModel)

	oModel:SetValue('FJRMASTER','FJR_CAMPO','1')

Return 

/*/{Protheus.doc} Fn842Commit
Função de ativação do modelo de dados.
@author William Matos Gundim Junior
@since 19/11/2014	
@version 12
/*/
Function Fn842Commit()
	Local oModel 	:= FWModelActive()
	Local lRet	 	:= .T.
	Local nX 		:= 0
	Local cLog 	:= ""

	If oModel:VldData()

		oModel:CommitData()
		oModel:DeActivate()	
		//
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()

	Else

		For nX := 1 To Len(oModel:GetErrorMessage())

			cLog += cValToChar(oModel:GetErrorMessage()[nX]) + CRLF   	 	 

		Next nX

		Help( ,,"MIGRADOR",,cLog, 1, 0 )

	EndIf

Return lRet 


/*/{Protheus.doc} Fn842FILIAIS
Permite a seleção das filiais das quais serão selecionados os registros 
para migração para o novo modelo de OP e Recibo.
@author Marcello Gabriel
@since 03/07/2015	
@version 12
/*/
Function Fn842Filiais(oBrwFil)
	Local nPos	:= 0
	Local nX	:= 0

	aLstFil := {}
	aSelFil := AdmGetFil(.F.,.F.,"SN3",,.F.)
	If !Empty(aSelFil)
		For nX := 1 To Len(aSelFil)
			nPos := Ascan(aLstSM0,{|sm0| sm0[SM0_GRPEMP] == cEmpAnt .And. sm0[SM0_CODFIL] == aSelFil[nX]})
			If nPos > 0
				Aadd(aLstFil,{aLstSM0[nPos,SM0_CODFIL],aLstSM0[nPos,SM0_NOMRED]})
			Endif
		Next
	Endif 
	oBrwFil:SetArray(aLstFil)
	oBrwFil:lVisible := (!Empty(aSelFil))
	oBrwFil:Refresh()
Return()
