#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TMKA710.CH"

#DEFINE INSERIR   1
#DEFINE IDUNICO   2
#DEFINE CODVEND	  38
#DEFINE CODUSER   39
#DEFINE OPERACAO  11
#DEFINE ENTIDADE  71                                                                   
#DEFINE NOME 	  72
#DEFINE DDD	  	  73
#DEFINE TELEFONE  74
#DEFINE EMAIL 	  75
#DEFINE ESTADO 	  76
#DEFINE MUNICIPIO 77
#DEFINE ENDERECO  78
#DEFINE OBS	  	  79
#DEFINE FOTO	  80
#DEFINE CHECK	  57
#DEFINE ASSOBS	  71
#DEFINE DATAIN	  7
#DEFINE HORA	  73
#DEFINE CODCLI	  10
#DEFINE EMAILIN   51
#DEFINE LATITUDE  26
#DEFINE LONGITUDE 27
#DEFINE DATAOUT	  7
#DEFINE DTHROUT	  6
#DEFINE EMAILOUT  44
#DEFINE VENDCHK	  38
#DEFINE	HORAOUT	  72

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMKA710()
Rotina responsavel pela importação do arquivo ftp uMov.me

@author Vendas CRM
@since 19/08/2013
/*/
//------------------------------------------------------------------------------------------------

Function TMKA710(cXml)

Local aArea 	  := GetArea()
Local aAreaSA3 	  := SA3->(GetArea())
Local aAreaACH 	  := ACH->(GetArea())
Local aAreaSUS 	  := SUS->(GetArea())
Local aAreaSA1 	  := SA1->(GetArea())
Local aAreaAD7 	  := AD7->(GetArea())
Local aAreaAOF 	  := AOF->(GetArea())
Local cLinha 	  := ""
Local cArq 	   	  := cXml
Local aDados 	  := {}
Local aCampos 	  := {}
Local aEntidade   := {}
Local cVincVend   := SuperGetMv("MV_VINCVEN")
Local cCodVend	  := ""
Local nX		  := 1
Local lMsExec 	  := ExistBlock("TK710Ent")
Local aEstrTmp	  := {}    
Local aEstruct	  := {} 
Local cEntidade	  := ""
Local bExecAuto   := {||}
Local cError	  := ""
Local cWarning	  := ""
Local nHandle
Local cUkey       := ""
Local aChave	  := {}
Local aAux		  := {}
Local cArquivo	  := ""
Local nY		  := 0
Local cRet		  := ""
Local lRet		  := .F.
Local oXml		  := Nil
Local cGetHrOut	  := ""
Local aErros	  := {}
Local aAutoErro := {}
Private INCLUI 	  := .T.
Private aRotina   := {} 
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

oXML := XmlParser(cArq,"_",@cError,@cWarning)

If XmlChildEx( oXML, "_UMOVIMPORT" ) <> Nil
	cCaminho := oXML:_UmovImport:_RelativeDirectory:Text+"\"+oXML:_UmovImport:_FileName:Text

	nHandle := FT_FUSE(cCaminho) //Abri o Arquivo.
	
	CONOUT(cCaminho)
	
	If nHandle == -1
		Conout(STR0001)//"Sem Arquivo Para Ser Importado."
	Endif
	
	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))
	
	DbSelectArea("AIO")
	AIO->(DbSetOrder(2))	//AIO_FILIAL+AIO_VEND+AIO_DATA+AIO_HORA
	
	While !FT_FEof()
		
		cLinha 		:= FT_FReadLn()
		cLinha 		:= TK710Limpar(cLinha)
		aDados 		:= Separa(cLinha,";")
			
		aCampos 	:= {}
		aEntidade	:= {}    
	    		
		If aDados[INSERIR] == STR0002 .AND. aDados[OPERACAO] == STR0003	//"INSERT"//"POSSAVEL CLIENTE"
			//Acha codigo do vendedor.
			If SA3->(DbSeek(xFilial("SA3")+aDados[CODVEND]))
				cCodVend := SA3->A3_COD
			EndIf
			
			If aDados[ENTIDADE] == STR0004//"Suspect"
   				aAdd(aEstrTmp,{"ACH_CODIGO"	,TK710GerCod("ACH")})
				aAdd(aEstrTmp,{"ACH_LOJA"	,STR0005})//"01"
				aAdd(aEstrTmp,{"ACH_TIPO"   ,STR0006})//"1"
				aAdd(aEstrTmp,{"ACH_RAZAO"	,Upper(aDados[NOME])})
				aAdd(aEstrTmp,{"ACH_DDD"	,aDados[DDD]})
				aAdd(aEstrTmp,{"ACH_TEL"	,aDados[TELEFONE]})
				aAdd(aEstrTmp,{"ACH_EMAIL"	,aDados[EMAIL]})
				aAdd(aEstrTmp,{"ACH_ORIGEM"	,"C"})
				aAdd(aEstrTmp,{"ACH_OBS"	,aDados[OBS]})
				aAdd(aEstrTmp,{"ACH_VEND"	,IIF(cVincVend == .T.,cCodVend,"") })
				aAdd(aEstrTmp,{"ACH_IMGUMO"	,aDados[FOTO]})
				
				cEntidade := STR0007//"ACH"
				
				aEstruct := TK710MntEstr("ACH",aEstrTmp)
				bExecAuto := {|| MSExecAuto({|x,y| TMKA341(x,y)},aEstruct,3) }
				
			ElseIf aDados[ENTIDADE] == STR0008//"Prospect"
				aAdd(aEstrTmp,{"US_COD"		,TK710GerCod("SUS")})
				aAdd(aEstrTmp,{"US_LOJA"	,STR0009})//"01"
				aAdd(aEstrTmp,{"US_NOME"    ,Upper(aDados[NOME])})
				aAdd(aEstrTmp,{"US_TIPO"	,STR0010})//"F"
				aAdd(aEstrTmp,{"US_EST"		,aDados[ESTADO]})
				aAdd(aEstrTmp,{"US_MUN"		,Upper(aDados[MUNICIPIO])})
				aAdd(aEstrTmp,{"US_END"		,Upper(aDados[ENDERECO])})
				aAdd(aEstrTmp,{"US_DDD"		,aDados[DDD]})
				aAdd(aEstrTmp,{"US_TEL"		,aDados[TELEFONE]})
				aAdd(aEstrTmp,{"US_EMAIL"	,aDados[EMAIL]})
				aAdd(aEstrTmp,{"US_ORIGEM"	,"C"})
				aAdd(aEstrTmp,{"US_OBS"		,aDados[OBS]})
				aAdd(aEstrTmp,{"US_VEND"	,IIF(cVincVend == .T.,cCodVend,"") })
				aAdd(aEstrTmp,{"US_IMGUMOV"	,aDados[FOTO]})
				
				cEntidade := STR0011//"SUS"
				
				aEstruct := TK710MntEstr("SUS",aEstrTmp)
				bExecAuto := {|| TMKA260(aEstruct,3)}
	        
			ElseIf aDados[ENTIDADE] == STR0012//"Cliente"
				aAdd(aEstrTmp,{"A1_COD"		,TK710GerCod("SA1")})
				aAdd(aEstrTmp,{"A1_LOJA"	,STR0013})//"01"
				aAdd(aEstrTmp,{"A1_NOME"    ,Upper(aDados[NOME])})
				aAdd(aEstrTmp,{"A1_NREDUZ"   ,Upper(aDados[NOME])})
				aAdd(aEstrTmp,{"A1_TIPO"	,STR0014})//"F"
				aAdd(aEstrTmp,{"A1_EST"		,aDados[ESTADO]})
				aAdd(aEstrTmp,{"A1_MUN"		,Upper(aDados[MUNICIPIO])})
				aAdd(aEstrTmp,{"A1_END"		,Upper(aDados[ENDERECO])})
				aAdd(aEstrTmp,{"A1_DDD"		,aDados[DDD]})
				aAdd(aEstrTmp,{"A1_TEL"		,aDados[TELEFONE]})
				aAdd(aEstrTmp,{"A1_EMAIL"	,aDados[EMAIL]})
				aAdd(aEstrTmp,{"A1_ORIGCT"	,"C"})
				aAdd(aEstrTmp,{"A1_OBSERV"	,aDados[OBS]})
				aAdd(aEstrTmp,{"A1_RECCOFI"	,STR0015})//"N"
				aAdd(aEstrTmp,{"A1_VEND"	,IIF(cVincVend == .T.,cCodVend,"")})
				aAdd(aEstrTmp,{"A1_IMGUMOV"	,aDados[FOTO]})
				
				cEntidade := "SA1"
	
				aEstruct := TK710MntEstr("SA1",aEstrTmp)
	
				bExecAuto := {|| MSExecAuto({|x,y| MATA030(x,y)},aEstruct,3)}
			
			EndIf
			
			If lMsExec
				aRet := ExecBlock("TK710Ent",.F.,.F.,{cEntidade,aEstruct})
				If ValType(aRet) == "A"
					aEstruct := aRet
				EndIf
			EndIf
			
			Eval(bExecAuto)

			If lMsErroAuto
				aAutoErro := GetAutoGrLog()
				LoguMov(aAutoErro)
			EndIf			
			
		EndIf
		
			If aDados[INSERIR] == STR0017 .AND. aDados[CHECK] == STR0016//"CHECK IN"//"INSERT"
			
				//Acha codigo do vendedor.
				If SA3->(DbSeek(aDados[VENDCHK]))
					cCodVend := SA3->A3_COD
				EndIf
				
				cCodEnt := aDados[CODCLI]			
				cData := SubStr(aDados[DATAIN],1,4)+SubStr(aDados[DATAIN],6,2)+SubStr(aDados[DATAIN],9,2)
				
				//Chamada da função que grava o check-in e verifica se já existe agenda.
				cTipo := "1"
				ChkInOut(aDados[HORA],cData,cCodEnt,aDados,cCodVend,cTipo)
							
			ElseIf aDados[INSERIR] == STR0019 .AND. aDados[CHECK] == STR0018//"CHECK OUT"//"INSERT"
				
				//Acha codigo do vendedor.
				If SA3->(DbSeek(aDados[VENDCHK]))
					cCodVend := SA3->A3_COD
				EndIf
				
				cCodEnt := aDados[CODCLI]
				cData := SubStr(aDados[DATAOUT],1,4)+SubStr(aDados[DATAOUT],6,2)+SubStr(aDados[DATAOUT],9,2)
				
				cTipo := "2"
				ChkInOut(aDados[HORAOUT],cData,cCodEnt,aDados,cCodVend,cTipo)
				
			EndIf
	 
		Asize( aCampos, 0)
		aCampos := Nil
		
		Asize( aDados, 0)
		aDados := Nil
		
		Asize( aEntidade, 0)
		aEntidade := Nil
		
		aStruct  := {}
		aEstrTmp := {}
		aRet	 := {}
			
		FT_FSkip()
		
	EndDo
	
	Ft_fuse()	//Fecha o arquivo
	
	RestArea(aAreaAD7)
	RestArea(aAreaAOF)
	RestArea(aAreaSA3)
	RestArea(aAreaACH)
	RestArea(aAreaSUS)
	RestArea(aAreaSA1)
	RestArea(aArea)

EndIf

Return {.T.,STR0028}//"Ok"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tk710VerImg()
Rotina responsavel carregar a imagem integrada.

@author Vendas CRM
@since 19/08/2013
/*/
//------------------------------------------------------------------------------------------------                                                           

Function Tk710VerImg(cEndereco)
//Função descontinuada (16/01/2019) - Remover no proximo Release
Return
 
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkInOut()
Rotina responsavel pela gravação e validação de check-in\out referente a agenda.

@author Vendas CRM
@since 14/04/2014
/*/
//------------------------------------------------------------------------------------------------

Static Function ChkInOut(aDados,cData,cCodEnt,aDados,cCodVend,cTipo)

Local aArea 	  := GetArea()
Local aAreaAIO 	  := AIO->(GetArea())
Local aAreaAD7 	  := AD7->(GetArea())
Local aAreaAOF	  := AOF->(GetArea())
Local cVend	  	  := cCodVend
Local cTipo		  := cTipo
Local cData		  := cData
Local cHrChk      := ""
Local cCod		  := ""
Local cHoraAge	  := ""
Local aEstrTmp	  := {}
Local aEstruct	  := {}
Local lMsExec  	  := ExistBlock("TK710Age")
Local aRet		  := {}
Local aTolera	  := {}
Local aHrGrvAD7	  := {}
Local cHora2      := ""
Local cAlias  	  := ""
Local lVersion	  := GetRpoRelease() >= "12.0"
	
If cTipo == "1" //Check-in

	If lVersion	//Versão 12
	
		DbSelectArea("AIO")
		DbSetOrder(1)	//AIO_FILIAL, AIO_IDAGE
	
			RecLock("AIO",.T.)
				AIO->AIO_FILIAL := xFilial("AIO")
				AIO->AIO_COD	:= GerCodAIO()
				AIO->AIO_VEND   := cCodVend
				AIO->AIO_TIPO   := IIF(aDados[CHECK] == STR0044,STR0042,STR0043)//"1"//"2"//"CHECK IN"
				AIO->AIO_DATA   := STOD(cData)
				AIO->AIO_ENT    := aDados[CODCLI] //10
				AIO->AIO_HORA   := IIF(cTipo == "1",SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5),SubStr(aDados[HORAOUT],1,2)+":"+SubStr(aDados[HORAOUT],4,5))
				AIO->AIO_LATITU := aDados[LATITUDE] //26
				AIO->AIO_LONGIT := aDados[LONGITUDE]//27
				AIO->AIO_ALIAS	:= "AOF"
				AIO->AIO_IDAGE	:= aDados[IDUNICO]
			AIO->(MsUnlock()) 

		cCod 	:= AIO->AIO_IDAGE
		cHrChk	:= SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5)   
	
		DbSelectArea("AOF")
		DbSetOrder(4)	//AOF_FILIALAOF_ENTIDA+AOF_CHAVE+DTOS(AOF_DTINIC)+AOF_HRINIC
		
		If Len(cCodEnt) == 19
			cAlias := SubStr(cCodEnt,17,3)
		Else
			cAlias := SubStr(cCodEnt,9,3)
		EndIf
	
	    // Adiciono no arrray aTolera os dados da Agenda que será feita a conferencia com o tempo de tolerancia.
	    If SubStr(cCodEnt,9,3) == "SA1"	//Cliente
	    
			If AOF->(DbSeek(AllTrim(xFilial("AOF")+cAlias+SubStr(cCodEnt,1,8)+cData)))
				While !AOF->(Eof()) .AND. AOF->AOF_FILIAL == xFilial("AOF") .AND. ;
					AOF->AOF_CHAVE == SubStr(cCodEnt,1,8) .AND. DTOS(AOF->AOF_DTINIC) == cData
					AAdd(aTolera,{AOF->AOF_CHAVE,AOF->AOF_DTINIC,AOF->AOF_HRINIC})
					AOF->(DbSkip())
				EndDo	
		    EndIf
		    
		 ElseIf SubStr(cCodEnt,17,3) == "SA1"
		 
			If AOF->(DbSeek(AllTrim(xFilial("AOF")+cAlias+SubStr(cCodEnt,9,8)+cData)))
				While !AOF->(Eof()) .AND. AOF->AOF_FILIAL == xFilial("AOF") .AND. ;
					AOF->AOF_CHAVE == SubStr(cCodEnt,9,8) .AND. ;
					DTOS(AOF->AOF_DTINIC) == cData
					AAdd(aTolera,{AOF->AOF_CHAVE,AOF->AOF_DTINIC,AOF->AOF_HRINIC})
					AOF->(DbSkip())
				EndDo	
		    EndIf
		    	 
		 EndIf
		    
		 If SubStr(cCodEnt,9,3) == "SUS"
		 
			If AOF->(DbSeek(AllTrim(xFilial("AOF")+SubStr(cCodEnt,9,3)+SubStr(cCodEnt,1,8)+cData)))
				While !AOF->(Eof()) .AND. AOF->AOF_FILIAL == xFilial("AOF") .AND. ;
					AOF->AOF_CHAVE == SubStr(cCodEnt,1,8) .AND. ;
					DTOS(AOF->AOF_DTINIC) == cData
					AAdd(aTolera,{AOF->AOF_CHAVE,AOF->AOF_DTINIC,AOF->AOF_HRINIC})
					AOF->(DbSkip())
				EndDo	
		    EndIf
		    
		 ElseIf SubStr(cCodEnt,17,3) == "SUS"
	
			If AOF->(DbSeek(AllTrim(xFilial("AOF")+cAlias+SubStr(cCodEnt,9,8)+cData)))
				While !AOF->(Eof()) .AND. AOF->AOF_FILIAL == xFilial("AOF") .AND. ;
					AOF->AOF_CHAVE == SubStr(cCodEnt,9,8) .AND. DTOS(AOF->AOF_DTINIC) == cData
					AAdd(aTolera,{AOF->AOF_CHAVE,AOF->AOF_DTINIC,AOF->AOF_HRINIC})
					AOF->(DbSkip())
				EndDo	
		    EndIf	 
	
		 EndIf

		//Se o tamanho do array aTolera for maior que zero significa que ja existe registro de agenda para a data e chamo a função para verificar
		// se será gravada uma nova agenda ou não
		
		If Len(aHrGrvAD7) > 0
			cHoraAge := ChkTolera(aHrGrvAD7,aDados[HORA],cCodEnt,cData)
		EndIf
	
			If !Empty(cHoraAge)	//Encontrou uma agenda que sera relacionada com o registro do check-in.
			
				DbSelectArea("AOF")
				If Len(cCodEnt) == 19
					cAlias := SubStr(cCodEnt,17,3)
				Else
					cAlias := SubStr(cCodEnt,9,3)
				EndIf
				
				If Len(cCodEnt) == 19
					If AOF->(DbSeek(AllTrim(xFilial("AOF")+cAlias+SubStr(cCodEnt,9,8)+cData)))
						RecLock("AOF",.F.)
							AOF->AOF_CODUMO	:= cCod 
						AOF->(MsUnlock())
					EndIf    
				Else
					IF AOF->(DbSeek(AllTrim(xFilial("AOF")+cAlias+SubStr(cCodEnt,1,8)+cData)))
						RecLock("AOF",.F.)
							AOF->AOF_CODUMO	:= cCod
						AOF->(MsUnlock())
					EndIf
				EndIf
	
			Else
	
				cCod 	:= AIO->AIO_IDAGE
				cHrChk	:= SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5)
				
				DbSelectArea("AOF")
				DbSetOrder(4)
				
				DbSelectArea("SA3")
				DbSetOrder(1)
				
				aAdd(aEstrTmp,{"AOF_FILIAL"	,xFilial("AOF")})
				aAdd(aEstrTmp,{"AOF_TIPO"	,"2"})
				aAdd(aEstrTmp,{"AOF_ASSUNT"	,SubStr(Upper(aDados[ASSOBS]),1,10)})
				aAdd(aEstrTmp,{"AOF_DESCRI"	,Upper(aDados[ASSOBS])})
				aAdd(aEstrTmp,{"AOF_DTINIC"	,STOD(cData)})
				aAdd(aEstrTmp,{"AOF_HRINIC"	,cHrChk})
				aAdd(aEstrTmp,{"AOF_DTFIM"	,STOD(cData)})
				aAdd(aEstrTmp,{"AOF_HRFIM"	,cHrChk})
				aAdd(aEstrTmp,{"AOF_ENTIDA"	,cAlias})
				If Len(cCodEnt) == 19
					aAdd(aEstrTmp,{"AOF_CHAVE"	,SubStr(cCodEnt,9,8)})
				Else
					aAdd(aEstrTmp,{"AOF_CHAVE"	,SubStr(cCodEnt,1,8)})
				EndIf
				aAdd(aEstrTmp,{"AOF_CODUSR"	,SubStr(aDados[CODUSER],1,6)})	
				aAdd(aEstrTmp,{"AOF_CODUMO"	,PegaIdAge(cCodVend,cData,cHrChk)})
				
				If lMsExec
					aRet := ExecBlock("TK710Age",.F.,.F.,{"AOF",aEstrTmp})
					If ValType(aRet) == "A"
						aEstruct := aRet
					EndIf
				EndIf
		
				lMsErroAuto := .F.
				CRMA180(aEstrTmp,3,.T.)
	
				If lMsErroAuto
					aAutoErro := GetAutoGrLog()
					LoguMov(aAutoErro)
				EndIf
			EndIf
		
	Else	//Anterior versão 12
 
		DbSelectArea("AIO")
		DbSetOrder(1)	//AIO_FILIAL, AIO_IDAGE
	
			RecLock("AIO",.T.)
				AIO->AIO_FILIAL := xFilial("AIO")
				AIO->AIO_COD	:= GerCodAIO()
				AIO->AIO_VEND   := cCodVend
				AIO->AIO_TIPO   := IIF(aDados[CHECK] == STR0044,STR0042,STR0043)//"1"//"2"//"CHECK IN"
				AIO->AIO_DATA   := STOD(cData)
				AIO->AIO_ENT    := aDados[CODCLI] //10
				AIO->AIO_HORA   := IIF(cTipo == "1",SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5),SubStr(aDados[HORAOUT],1,2)+":"+SubStr(aDados[HORAOUT],4,5))
				AIO->AIO_LATITU := aDados[LATITUDE] //26
				AIO->AIO_LONGIT := aDados[LONGITUDE]//27
				AIO->AIO_ALIAS	:= "AD7"
				AIO->AIO_IDAGE	:= aDados[IDUNICO]
			AIO->(MsUnlock()) 

		cCod 	:= AIO->AIO_IDAGE
		cHrChk	:= SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5)   	
		
		DbSelectArea("AD7")     
	
		If Len(cCodEnt) == 19
			If SubStr(cCodEnt,17,3) == "SA1"
				AD7->(DbSetOrder(10))	//Cliente
			ElseIf SubStr(cCodEnt,17,3) == "SUS"
				AD7->(DbSetOrder(11))	//Prospect	
			EndIf	
		Else
			If SubStr(cCodEnt,9,3) == "SA1"
				AD7->(DbSetOrder(10))	//Cliente
			ElseIf (cCodCli,9,3) == "SUS"
				AD7->(DbSetOrder(11))	//Prospect
			EndIf
		EndIf
	
		//Cliente
		If SubStr(cCodEnt,9,3) == "SA1"
			AD7->(DbSetOrder(10))	//AD7_FILIAL, AD7_CODCLI, AD7_LOJA, AD7_DATA, AD7_HORA1
			If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,1,8)+cData))
				While !AD7->(Eof()) .AND. AD7->AD7_FILIAL == xFilial("AD7") .AND. AD7->AD7_CODCLI+AD7->AD7_LOJA == SubStr(cCodEnt,1,8) .AND. DTOS(AD7->AD7_DATA) == cData
					AAdd(aHrGrvAD7,{AD7->AD7_CODUMO,AD7->AD7_HORA1})
				AD7->(DbSkip())
				EndDo	
			EndIf
		
		ElseIf SubStr(cCodEnt,17,3) == "SA1"
			AD7->(DbSetOrder(10))	//AD7_FILIAL, AD7_CODCLI, AD7_LOJA, AD7_DATA, AD7_HORA1
			If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,9,8)+cData))
				While !AD7->(Eof()) .AND. AD7->AD7_FILIAL == xFilial("AD7") .AND. AD7->AD7_CODCLI+AD7->AD7_LOJA == SubStr(cCodEnt,9,8) .AND. DTOS(AD7->AD7_DATA) == cData
					AAdd(aHrGrvAD7,{AD7->AD7_CODUMO,AD7->AD7_HORA1})
				AD7->(DbSkip())
				EndDo	
			EndIf
		EndIf
	    
		//Prospect
		If SubStr(cCodEnt,9,3) == "SUS"
			AD7->(DbSetOrder(11))	//AD7_FILIAL, AD7_PROSCLI, AD7_LOJPRO, AD7_DATA, AD7_HORA1
			If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,1,8)+cData))
				While !AD7->(Eof()) .AND. AD7->AD7_FILIAL == xFilial("AD7") .AND. AD7->AD7_PROSPE+AD7->AD7_LOJPRO == SubStr(cCodEnt,1,8) .AND. DTOS(AD7->AD7_DATA) == cData
					AAdd(aHrGrvAD7,{AD7->AD7_CODUMO,AD7->AD7_HORA1})
				AD7->(DbSkip())
				EndDo	
		    EndIf
		ElseIf SubStr(cCodEnt,17,3) == "SUS"
			AD7->(DbSetOrder(11))	//AD7_FILIAL, AD7_PROSCLI, AD7_LOJPRO, AD7_DATA, AD7_HORA1
			If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,9,8)+cData))
				While !AD7->(Eof()) .AND. AD7->AD7_FILIAL == xFilial("AD7") .AND. AD7->AD7_PROSPE+AD7->AD7_LOJPRO == SubStr(cCodEnt,9,8) .AND. DTOS(AD7->AD7_DATA) == cData
					AAdd(aHrGrvAD7,{AD7->AD7_CODUMO,AD7->AD7_HORA1})
				AD7->(DbSkip())
				EndDo	
		    EndIf
		EndIf
	    
		//Se o tamanho do array aTolera for maior que zero significa que ja existe registro de agenda para a data e chamo a função para verificar
		// se será gravada uma nova agenda ou não
		
		If Len(aHrGrvAD7) > 0
			cHoraAge := ChkTolera(aHrGrvAD7,aDados[HORA],cCodEnt,cData)
		EndIf
	
			If !Empty(cHoraAge)	//Encontrou uma agenda que sera relacionada com o registro do check-in.
			
				DbSelectArea("AD7")
				If Len(cCodEnt) == 19
					If SubStr(cCodEnt,17,3) == "SA1"
						AD7->(DbSetOrder(10))	//Cliente
					ElseIf SubStr(cCodEnt,17,3) == "SUS"
						AD7->(DbSetOrder(11))	//Prospect	
					EndIf	
				Else
					If SubStr(cCodEnt,9,3) == "SA1"
						AD7->(DbSetOrder(10))	//Cliente
					ElseIf (cCodCli,9,3) == "SUS"
						AD7->(DbSetOrder(11))	//Prospect
					EndIf
				EndIf
				
				If Len(cCodEnt) == 19
					If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,9,8)+cData+SubStr(cHoraAge,1,5)))   
						RecLock("AD7",.F.)
							AD7->AD7_CODUMO	:= cCod 
						AD7->(MsUnlock())
					EndIf    
				Else
					If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,1,8)+cData+SubStr(cHoraAge,1,5)))
						RecLock("AD7",.F.)
							AD7->AD7_CODUMO := cCod 
						AD7->(MsUnlock())
					EndIf
				EndIf
	
			Else
	
				cCod 	:= AIO->AIO_IDAGE
				cHrChk	:= SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5)
				
				DbSelectArea("AD7")
				DbSetOrder(1)
	
				aAdd(aEstrTmp,{"AD7_FILIAL"	,xFilial("AD7")})
				aAdd(aEstrTmp,{"AD7_TOPICO"	,Upper(aDados[ASSOBS])})
				aAdd(aEstrTmp,{"AD7_DATA"	,STOD(cData)})
				aAdd(aEstrTmp,{"AD7_HORA1"	,cHrChk})
				aAdd(aEstrTmp,{"AD7_HORA2"	,cHrChk})
				aAdd(aEstrTmp,{"AD7_ALERTA"	,0})
				aAdd(aEstrTmp,{"AD7_TIPO"	,""})
				If SubStr(cCodEnt,9,3) == "SA1"
					If Len(cCodEnt) == 19
						aAdd(aEstrTmp,{"AD7_CODCLI"	,SubStr(cCodEnt,9,6)})
						aAdd(aEstrTmp,{"AD7_LOJA"	,SubStr(cCodEnt,15,2)})
					Else
						aAdd(aEstrTmp,{"AD7_CODCLI"	,SubStr(cCodEnt,1,6)})
						aAdd(aEstrTmp,{"AD7_LOJA"	,SubStr(cCodEnt,7,2)})
					EndIf
				ElseIf SubStr(cCodEnt,9,3) == "SUS"
					If Len(cCodEnt) == 19
						aAdd(aEstrTmp,{"AD7_CODCLI"	,SubStr(cCodEnt,9,6)})
						aAdd(aEstrTmp,{"AD7_LOJA"	,SubStr(cCodEnt,15,2)})
					Else
						aAdd(aEstrTmp,{"AD7_PROSPE"	,SubStr(cCodEnt,1,6)})
						aAdd(aEstrTmp,{"AD7_LOJAPRO",SubStr(cCodEnt,7,2)})
					EndIf
				EndIf
				aAdd(aEstrTmp,{"AD7_VEND"	,cCodVend})
				aAdd(aEstrTmp,{"AD7_CODUMO"	,PegaIdAge(cCodVend,cData,cHrChk)})
				
				If lMsExec
					aRet := ExecBlock("TK710Age",.F.,.F.,{STR0040,aEstrTmp})//"AD7"
					If ValType(aRet) == "A"
						aEstruct := aRet
					EndIf
				EndIf
		
				aAux := TK710MntEstrTES("AD7",aEstrTmp)
				aAdd(aEstruct,aAux)
				lMsErroAuto := .F.
				Ft320Age(dDataBase,,aEstruct)
	
				If lMsErroAuto
					aAutoErro := GetAutoGrLog()
					LoguMov(aAutoErro)
				EndIf
				 
			EndIf
	EndIf		

EndIf

If cTipo == "2"

cHora2 := SubStr(aDados[HORAOUT],1,2)+":"+SubStr(aDados[HORAOUT],4,5)
	
	If lVersion	//Versão 12
	
		DbSelectArea("AOF")
		DbSetOrder(7)	//AOF_FILIAL+AOF_CODUMO
		
		If DbSeek(xFilial("AOF")+aDados[IDUNICO])
			RecLock("AOF",.F.)
				If AOF->AOF_HRINIC == AOF->AOF_HRFIM .AND. AOF->AOF_HRFIM <= cHora2
					AOF->AOF_HRFIM  := cHora2
				EndIf
				AOF->AOF_CODUMO	:= aDados[IDUNICO] 
			AD7->(MsUnlock())

		RecLock("AIO",.T.)
		AIO->AIO_FILIAL := xFilial("AIO")
		AIO->AIO_COD	:= GerCodAIO()
		AIO->AIO_VEND   := cCodVend
		AIO->AIO_TIPO   := IIF(aDados[CHECK] == STR0044,STR0042,STR0043)//"1"//"2"//"CHECK IN"
		AIO->AIO_DATA   := STOD(cData)
		AIO->AIO_ENT    := aDados[CODCLI] //10
		AIO->AIO_HORA   := SubStr(aDados[HORAOUT],1,2)+":"+SubStr(aDados[HORAOUT],4,5)
		AIO->AIO_LATITU := aDados[LATITUDE] //26
		AIO->AIO_LONGIT := aDados[LONGITUDE]//27
		AIO->AIO_ALIAS	:= "AOF"
		AIO->AIO_IDAGE	:= aDados[IDUNICO] //2
		AIO->(MsUnlock())
		
		Else
		
			DbSelectArea("AIO")
			DbSetOrder(4)	//AIO_FILIAL, AIO_IDAGE
			
			RecLock("AIO",.T.)
			AIO->AIO_FILIAL := xFilial("AIO")
			AIO->AIO_COD	:= GerCodAIO()
			AIO->AIO_VEND   := cCodVend
			AIO->AIO_TIPO   := IIF(aDados[CHECK] == STR0044,STR0042,STR0043)//"1"//"2"//"CHECK IN"
			AIO->AIO_DATA   := STOD(cData)
			AIO->AIO_ENT    := aDados[CODCLI] //10
			AIO->AIO_HORA   := IIF(cTipo == "1",SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5),SubStr(aDados[HORAOUT],1,2)+":"+SubStr(aDados[HORAOUT],4,5))
			AIO->AIO_LATITU := aDados[LATITUDE] //26
			AIO->AIO_LONGIT := aDados[LONGITUDE]//27
			AIO->AIO_ALIAS	:= "AOF"
			AIO->AIO_IDAGE	:= aDados[IDUNICO]	//2
			AIO->(MsUnlock())
			
		EndIf			
		
    Else	//Anterior versão 12

		DbSelectArea("AD7")
		DbSetOrder(12)	//AD7_FILIAL+AD7_CODUMO
	
		If DbSeek(xFilial("AD7")+aDados[2]) //Encontrar na AD7.
			RecLock("AD7",.F.)
				If AD7->AD7_HORA1 == AD7->AD7_HORA2 .AND. AD7->AD7_HORA2 <= cHora2
					AD7->AD7_HORA2  := cHora2
				EndIf
				AD7->AD7_CODUMO	:= aDados[IDUNICO]
			AD7->(MsUnlock())
	
			DbSelectArea("AIO")
			DbSetOrder(4)	//AIO_FILIAL, AIO_IDAGE
			
			RecLock("AIO",.T.)
			AIO->AIO_FILIAL := xFilial("AIO")
			AIO->AIO_COD	:= GerCodAIO()
			AIO->AIO_VEND   := cCodVend
			AIO->AIO_TIPO   := IIF(aDados[CHECK] == STR0044,STR0042,STR0043)//"1"//"2"//"CHECK IN"
			AIO->AIO_DATA   := STOD(cData)
			AIO->AIO_ENT    := aDados[CODCLI] //10
			AIO->AIO_HORA   := SubStr(aDados[HORAOUT],1,2)+":"+SubStr(aDados[HORAOUT],4,5)
			AIO->AIO_LATITU := aDados[LATITUDE] //26
			AIO->AIO_LONGIT := aDados[LONGITUDE]//27
			AIO->AIO_ALIAS	:= STR0046//"AD7"
			AIO->AIO_IDAGE	:= aDados[IDUNICO] //2
			AIO->(MsUnlock())		
		
		Else
		
			DbSelectArea("AIO")
			DbSetOrder(4)	//AIO_FILIAL, AIO_IDAGE
			
			RecLock("AIO",.T.)
			AIO->AIO_FILIAL := xFilial("AIO")
			AIO->AIO_COD	:= GerCodAIO()
			AIO->AIO_VEND   := cCodVend
			AIO->AIO_TIPO   := IIF(aDados[CHECK] == STR0044,STR0042,STR0043)//"1"//"2"//"CHECK IN"
			AIO->AIO_DATA   := STOD(cData)
			AIO->AIO_ENT    := aDados[CODCLI] //10
			AIO->AIO_HORA   := IIF(cTipo == "1",SubStr(aDados[HORA],1,2)+":"+SubStr(aDados[HORA],4,5),SubStr(aDados[HORAOUT],1,2)+":"+SubStr(aDados[HORAOUT],4,5))
			AIO->AIO_LATITU := aDados[LATITUDE] //26
			AIO->AIO_LONGIT := aDados[LONGITUDE]//27
			AIO->AIO_ALIAS	:= STR0046//"AD7"
			AIO->AIO_IDAGE	:= aDados[IDUNICO]	//2
			AIO->(MsUnlock())
			
		EndIf

	EndIf
		
EndIf

RestArea(aAreaAOF)		
RestArea(aAreaAD7)
RestArea(aAreaAIO)
RestArea(aArea)

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkTolera()
Verifica a tolerancia das agendas.
@Return cTempo - Tempo da tolerancia.
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function ChkTolera(aTolera,cHora,cCodEnt,cData)

Local cTempo  := ""
Local cTolera  := SuperGetMV("MV_AGEHRME",.T.,"00:00:00")
Local cHoraAge := ""
Local cHora	   := cHora+":00"
Local cTemMed  := ""
Local nX	   := 1
Local nY	   := 3
Local nZ	   := 1
Local aRet	   := {}
Local aDifTime := {}
Local lVersion := GetRpoRelease() >= "12.0"

If lVersion	//Versão 12

	DbSelectArea("AOF")
	DbSetOrder(4)	//AOF_FILIAL+AOF_ENTIDA+AOF_CHAVE+DTOS(AOF_DTINIC)+AOF_HRINIC
			
	If Len(cCodEnt) == 19
		cAlias := SubStr(cCodEnt,17,3)
	Else
		cAlias := SubStr(cCodEnt,9,3)
	EndIf

	//Fazer comparativa dos horarios mais proximos.
	For nZ := 1 To Len(aRet)
	
		If aRet[nZ]+":00" >= cHora
			cTemMed := ElapTime(cHora,aRet[nZ]+":00")
			Aadd(aDifTime,{cTemMed,aRet[nZ]})
	    Else
	    	cTemMed := ElapTime(aRet[nZ]+":00",cHora)
	    	Aadd(aDifTime,{cTemMed,aRet[nZ]})
	    EndIf
	    
	Next nZ 
	
	//Ordena do menor para o maior, o menor será o registro utilizado.
	aSort(aDifTime,,,{|x,y| x[1] < y[1]})
	
	If aDifTime[1,1] <= cTolera
	
		If Len(cCodEnt) == 19
			If AOF->(DbSeek(AllTrim(xFilial("AOF")+cAlias+SubStr(cCodEnt,9,8)+cData)))
				cTempo := AOF->AOF_HRINIC+":00"
			EndIf    
		Else
			If AOF->(DbSeek(AllTrim(xFilial("AOF")+cAlias+SubStr(cCodEnt,1,8)+cData)))
				cTempo := AOF->AOF_HRINIC+":00"
			EndIf
		EndIf
			
	Else
		//Retorno branco será criada uma nova agenda.
		cTempo := ""
	
	EndIf

Else

	//Cliente
	If Len(cCodEnt) == 19
		If SubStr(cCodEnt,17,3) == "SA1"
			AD7->(DbSetOrder(10))
		EndIf
	Else
		If SubStr(cCodEnt,9,3) == "SA1"
			AD7->(DbSetOrder(10))
		EndIf
	EndIf
	
	//Prospect
	If Len(cCodEnt) == 19
		If SubStr(cCodEnt,17,3) == "SUS"
			AD7->(DbSetOrder(11))	//Cliente
		EndIf
	Else
		If SubStr(cCodEnt,9,3) == "SUS"
			AD7->(DbSetOrder(11))
		EndIf
	EndIf
	
	For nX := 1 To Len(aTolera)
		Aadd(aRet,aTolera[nX,nY])
	Next nX
	
	//Fazer comparativa dos horarios mais proximos.
	For nZ := 1 To Len(aRet)
	
		If aRet[nZ]+":00" >= cHora
			cTemMed := ElapTime(cHora,aRet[nZ]+":00")
			Aadd(aDifTime,{cTemMed,aRet[nZ]})
	    Else
	    	cTemMed := ElapTime(aRet[nZ]+":00",cHora)
	    	Aadd(aDifTime,{cTemMed,aRet[nZ]})
	    EndIf
	    
	Next nZ 
	
	//Ordena do menor para o maior, o menor será o registro utilizado.
	aSort(aDifTime,,,{|x,y| x[1] < y[1]})
	
	If aDifTime[1,1] <= cTolera
	
	    If Len(cCodEnt) == 19
		    If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,9,8)+cData+aDifTime[1,2]))   
				cTempo := AD7->AD7_HORA1+":00"
			EndIf    
	    Else
		    If AD7->(DbSeek(xFilial("AD7")+SubStr(cCodEnt,1,8)+cData+aDifTime[1,2]))   
				cTempo := AD7->AD7_HORA1+":00"
			EndIf
		EndIf	
	
	Else
		//Retorno branco será criada uma nova agenda.
		cTempo := ""
	
	EndIf

EndIf

Return cTempo

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PegaIdAge()
Função responsavel por busca o registro de check-in\out correto.
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function PegaIdAge(cCodVend,cData,cHora)

Local cCodAge := ""

DbSelectArea("AIO")     // levar para fora do while
AIO->(DbSetOrder(2))	//AIO_FILIAL+AIO_VEND+AIO_TIPO+AIO_DATA+AIO_HORA

If AIO->(DbSeek(xFilial("AIO")+cCodVend+"1"+cData+cHora))
	cCodAge := AIO->AIO_IDAGE
EndIf

Return cCodAge

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK710MntEstrTES()
Valida os campos do execauto.

@Return aEstruct - Array com dados a serem gravados pelo execauto. 
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function TK710MntEstrTES(cEntidade,aEstrTmp)

Local aEstruct := {}
Local nPos 	:= 0

DBSelectArea("SX3")
DbSetOrder(1)

If DbSeek(cEntidade)
	While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cEntidade
	    If X3Uso(SX3->X3_USADO) .AND. SX3->X3_CONTEXT <> "V"
			nPos := aScan(aEstrTmp,{|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})
			If nPos >= 1
				Aadd(aEstruct,{aEstrTmp[nPos][1],aEstrTmp[nPos][2],Nil})
			EndIf
		EndIf		
	SX3->(DbSkip())
	EndDo
EndIf

Return aEstruct

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK710GerCod()
Valida os campos do execauto.

@Return aEstruct - Array com dados a serem gravados pelo execauto. 
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Function TK710GerCod(cEntidade)

Local aArea 	  := GetArea()
Local aAreaEnt 	  := (cEntidade)->(GetArea())
Local cCodProx 	  := ""

DbSelectArea("SX5")               
DbSetOrder(1)

DbSelectArea(cEntidade)
DbSetOrder(1)

If SX5->(DbSeek(xFilial("SX5")+STR0058))//"UV"
	cCodProx := Soma1(SX5->X5_CHAVE)
	If !((cEntidade)->(DbSeek(xFilial(cEntidade)+cCodProx)))
		RecLock("SX5",.F.)
			SX5->X5_CHAVE := cCodProx
		SX5->(MsUnlock())
	EndIf
EndIf

RestArea(aAreaEnt)
RestArea(aArea)

Return cCodProx

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerCodAIO()
Retorna o cadigo do registro do check-in\out.

@Return cCodProx - Codigo da entidade.
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function GerCodAIO()

Local cCodProx 	  := ""

DbSelectArea("SX5")
DbSetOrder(1)

If SX5->(DbSeek(xFilial("SX5")+"AW"))
	cCodProx := Soma1(SX5->X5_CHAVE)
		RecLock("SX5",.F.)
			SX5->X5_CHAVE := cCodProx
		SX5->(MsUnlock())
EndIf

Return cCodProx

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmkaSeqAge()
Valida os campos do execauto.

@Return cCod - Codigo do registro.
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function TmkaSeqAge()

Local cCodProx 	  := ""

DbSelectArea("SX5")
DbSetOrder(1)

If SX5->(DbSeek(xFilial("SX5")+"AG"))
	cCodProx := Soma1(SX5->X5_CHAVE)
		RecLock("SX5",.F.)
			SX5->X5_CHAVE := cCodProx
		SX5->(MsUnlock())
EndIf

Return cCodProx

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TK710Limpar()
Remove a acentuação.

@Return cRet - string sem acentuação.
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function TK710Limpar(cTxt)


Local cRet	:= ""
Local nX	:= 0

For nX := 1 To Len(cTxt)
	If SubStr(cTxt,nX,1) $ "ÃÁÂÀÇÉÊÈÍÎÌÓÕÔÒÚÛÙãáâàçéêèíîìóõôòúûù,'~"
		If SubStr(cTxt,nX,1) == ","
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "'"
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "~"
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "-"
			cRet += " "
		ElseIf SubStr(cTxt,nX,1) == "Ã"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Á"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Â"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "À"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "Ç"
			cRet += "C"
		ElseIf SubStr(cTxt,nX,1) == "É"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "Ê"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "È"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "Í"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Î"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Ì"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "Ó"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Õ"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ô"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ò"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "Ú"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "Û"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "Ù"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "ã"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "á"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "â"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "à"
			cRet += "A"
		ElseIf SubStr(cTxt,nX,1) == "ç"
			cRet += "C"
		ElseIf SubStr(cTxt,nX,1) == "é"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "ê"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "è"
			cRet += "E"
		ElseIf SubStr(cTxt,nX,1) == "í"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "î"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "ì"
			cRet += "I"
		ElseIf SubStr(cTxt,nX,1) == "ó"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "õ"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ô"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ò"
			cRet += "O"
		ElseIf SubStr(cTxt,nX,1) == "ú"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "û"
			cRet += "U"
		ElseIf SubStr(cTxt,nX,1) == "ù"
			cRet += "U"
		EndIf
	Else
		cRet += SubStr(cTxt,nX,1)
	EndIf
	
Next nX

Return AllTrim(cRet)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoguMov()
Cria log na system caso exista problemas na importação dos registros.

@Return cRet - string sem acentuação.
@author Vendas CRM
@since 22/08/2013
/*/
//------------------------------------------------------------------------------------------------

Static Function LoguMov(aErros)

Local nX     	:= 0
Local cLogFile 	:= ""
Local nHandle
Local lRet 		:= .F.
Local nRet		:= MakeDir("\APPCRM")

  If nRet != 0
    Conout( STR0060 + cValToChar( FError() ) )	//"Nao foi possivel criar o diretorio de log. Erro: "
  EndIf 

cLogFile := "APPCRM\"+"TMKA710"+".LOG"

	//Efetua o tratamento para validar se o arquivo de log já existe
	If !File(cLogFile)
		If (nHandle := MSFCreate(cLogFile,0)) <> -1
			lRet := .T.
		EndIf
	Else
		If (nHandle := FOpen(cLogFile,2)) <> -1
			FSeek(nHandle,0,2)
			lRet := .T.
		EndIf
	EndIf

	If	lRet	
		//Grava as informações de log no arquivo especificado
		For nX := 1 To Len(aErros)
			FWrite(nHandle,aErros[nX]+CHR(13)+CHR(10))
		Next nX
		
		FClose(nHandle)
	EndIf

Return
