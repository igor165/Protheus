#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA260.CH"
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    31/07/2014        ³  243473   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 
/*******************************************************************
* Funcao: PWSA260
* Autor: Marcelo Faria
* Data: 27/03/2012
* Portal RH de Dados Cadastrais (Projeto P12 - Requisito 126)
********************************************************************/
Web Function PWSA260()

	Local cHtml   	:= ""

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "CAD"		// Dados Cadastrais
		HttpGet->titulo           := STR0001 	//"Solicitacao de Acao Salarial"
		HttpGet->objetivo           := STR0002
		HttpSession->aStructure   	:= {}
		HttpSession->cHierarquia  	:= ""
		
		fGetInfRotina("W_PWSA260.APW")   		//Retorno HttpSession->aInfRotina
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA260A")
	WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA261
* Autor: Marcelo Faria
* Data: 27/03/2012
* Manutenção de Dados Cadastrais - interacao
********************************************************************/
Web Function PWSA261()
Local cHtml      := ""
Local nIndice    := 0
Local nX, nY     := 0
Local oWSFunc
Local oCampos
Local oHeaderData

if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif

WEB EXTENDED INIT cHtml START "InSite"  
	 //Pega filial e matricula do participante
    GetMat() 

   	If (HttpGet->nOperacao == "1")  
   		HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]

		//Busca dados do funcionario
		oWSFunc := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHEMPLOYEEREGISTRATION"), WsRHEMPLOYEEREGISTRATION():New())
		WsChgURL(@oWSFunc, "RHEMPLOYEEREGISTRATION.apw" ,,,GetEmpFun())

		oWSFunc:cEmployeeFil 	:= HttpSession->DadosFunc:cEmployeeFilial
		oWSFunc:cRegistration	:= HttpSession->DadosFunc:cRegistration
		oWSFunc:cEmployeeEmp    := HttpSession->DadosFunc:cEmployeeEmp

		If oWSFunc:GetRegEmployee()
			aFieldsEmp		:= oWSFunc:oWSGetRegEmployeeResult

			If "avatar.gif" $(aFieldsEmp:cEmployeeImg)
				HttpSession->_IMG_INST := ""
			Else					
				HttpSession->_IMG_INST := aFieldsEmp:cEmployeeImg
			EndIf	
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf
	EndIf


    If len(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT) > 0

		//Processa grupos da consulta de dados cadastrais
		oHeaderGroup := {}

		For nX:=1 To Len(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT)

			 //Processa itens do grupo
		    HttpSession->aHeader := {}

		    If len(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD) > 0

				For nY:=1 To Len(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD)

				   If aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDTYPE == "D" .and. ;
				      !empty(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDVAL)		
				       aAdd( HttpSession->aHeader , { aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDDESC ,      ;
				       	                       SubStr(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDVAL,7,2)  ;
				       	                       +'/'                                                                                                              ;
				       	                       +SubStr(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDVAL,5,2) ;
				       	                       +'/'                                                                                                              ;
				       	                       +SubStr(aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDVAL,1,4),;
				       	                        aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDTYPE} )
                 Else
				       aAdd( HttpSession->aHeader , { aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDDESC , ;
				       	                           aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDVAL,;
				       	                           aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:OWSLISTOFFIELDSSTRUCT:OWSDATAFIELD[nY]:CFIELDTYPE   } )
				   EndIf

				Next nY

           EndIf
		
			//Realiza a chamada para o ponto de entrada PgchHeader, a cada grupo da consulta
			//com o objetivo de realizar ajustes nas informações dos dados cadastrais
          If len(HttpSession->aHeader) > 0  

				If ExistBlock("PGCHHEADER") 
                 ProcHeaderAval('cons-cad')
              EndIf   

             //Monta resultado com as informações a serem renderizadas no html	
             oHeaderData  := {}
             oHeaderData  := WsClassNew('FieldsStruct')
             oHeaderData:Group              := aFieldsEmp:OWSLISTOFFIELDSGROUP:OWSFIELDSSTRUCT[nX]:CGROUP
             oHeaderData:ListOfFieldsStruct := {}

             For nY := 1 To Len( HttpSession->aHeader )
                 oCampos := WsClassNew('Topic')
                 oCampos:TitleHead := HttpSession->aHeader[nY][1]
                 oCampos:Content   := HttpSession->aHeader[nY][2]
                 oCampos:TypeField := HttpSession->aHeader[nY][3]

                 //Adiciona registros atualizados do grupo
                 aadd(oHeaderData:ListOfFieldsStruct, oCampos)	
             Next nY
	    	EndIf 

          //Adiciona grupo validado do resultado
			aadd(oHeaderGroup, oHeaderData)
	    	  
		Next nX
		
    EndIf

    cHtml := ExecInPage( "PWSA261" )
	
WEB EXTENDED END
Return cHtml
