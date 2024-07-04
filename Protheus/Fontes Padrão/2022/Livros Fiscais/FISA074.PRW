#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA074

Rotina de importação do Arquivo XML de consultas Inovar Auto.

@return Nil

@author Cleber Maldonado
@since 06/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fisa074()
Local	cTipoArq	:=	""

If Pergunte("FSA074")
	cTipoArq := Alltrim(Str(MV_PAR01))
	//a partir do rootpath do ambiente     
	cFile	 := Alltrim(MV_PAR02)+Alltrim(MV_PAR03)
	Fis74Imp(cTipoArq,cFile)
Else
	Alert("Processo cancelado!")
Endif

Return              
//-------------------------------------------------------------------
/*/{Protheus.doc} FIS74IMP

Rotina de importação do Arquivo XML de consultas Inovar Auto.

@return Nil

@author Cleber Maldonado
@since 06/06/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Fis74Imp(cTipo,cArq)
Local	nX			:= 0
Local	nY			:= 0  
Local	nG			:= 0
Local	nOpc		:= 0 //0 - Valor inicial terá que ganhar algum valor para executar alguma ação. 1 - Retorno da mensagem de aviso para sobreescrever. 2 - retorno da mensagem de aviso para manter os dados existentes. 3 - não existe na base será gravado na F02
Local	nEmp		:= 0
Local	nOper		:= 0
Local	aGrava		:= {}
Local	cIsOBJ		:= ""
Local	cRazFor		:= ""
Local	cCNPJFor	:= ""
Local	cMesRef		:= ""
Local	cAnoRef		:= ""
Local	cVlNotas	:= "0.00"
Local	cVlDedut	:= "0.00"
Local	cError		:=	"Erro ao importar o arquivo!"
Local	cWarning	:=	"Ocorreu um erro na leitura do arquivo."
Local	lContinua	:= .T.
Private	oXml		:= NIl // Necessário ser Private para que a função TYPE() consiga avaliar se existe ou não a propriedade TNS_VENDAS e _TNS_NAOINFORMACAOVENDAS, caso seja usado ValType(), se as propriedades não existirem, será gerado error.log

DEFAULT cTipo := ""
DEFAULT cArq  := ""

//Gera o Objeto XML
If File(cArq)
	oXml := XmlParserFile( cArq, "_", @cError, @cWarning)
Else
	AVISO("Atenção!","Arquivo não encontrado!. Verifique o caminho a apartir do Rootpath e o nome do arquivo",{"OK"},1)
	lContinua := .F.
Endif

dbSelectArea("F02")
dbSetOrder(1)

If lContinua .And. cTipo == "1" .And. Type( 'oXml:_TNS_VENDAS' ) <> "U"
	If ValType(oXML) == "O" 
		//Verifica se tem mais de uma empresa 
		cIsOBJ 	:= Valtype(OXML:_TNS_VENDAS:_TNS_EMPRESA)
		nEmp	:= IIF(cIsOBJ == "A",Len(OXML:_TNS_VENDAS:_TNS_EMPRESA),1)		
		For nX := 1 To nEmp
			//Verifica se tem mais de uma operação
			cIsOBJ 		:= Valtype(OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO)
			nOper		:= IIF(cIsOBJ == "A",Len(OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO),1)
			If Valtype(OXML:_TNS_VENDAS:_TNS_EMPRESA) == "A"			
				cMatriz 	:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_MATRIZ:TEXT
				cRazao		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_RAZAO_SOCIAL:TEXT
				cCNPJ		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_CNPJ:TEXT		
			Else
				cMatriz 	:= OXML:_TNS_VENDAS:_TNS_EMPRESA:_TNS_MATRIZ:TEXT
				cRazao		:= OXML:_TNS_VENDAS:_TNS_EMPRESA:_TNS_RAZAO_SOCIAL:TEXT
				cCNPJ		:= OXML:_TNS_VENDAS:_TNS_EMPRESA:_TNS_CNPJ:TEXT
			Endif
			For nY = 1 To nOper
				If ValType(OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO) == "A"
					cRazFor		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_RAZAO_SOCIAL:TEXT
					cCNPJFor	:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_CNPJ:TEXT
					cMesRef		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_MES_REF:TEXT
					cAnoRef		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_ANO_REF:TEXT
					cVlNotas	:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_VL_TOTAL_NOTAS:TEXT
					cVlDedut	:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_VL_PARC_DEDUTIVEL:TEXT
				Else               
					cRazFor		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_RAZAO_SOCIAL:TEXT			
					cCNPJFor	:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_CNPJ:TEXT
					cMesRef		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_MES_REF:TEXT
					cAnoRef		:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_ANO_REF:TEXT
					cVlNotas	:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_VL_TOTAL_NOTAS:TEXT
					cVlDedut	:= OXML:_TNS_VENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_VL_PARC_DEDUTIVEL:TEXT				
				Endif
			cMesRef := IIF(Len(cMesRef)==1,"0"+cMesRef,cMesRef)
			AADD(aGrava,{xFilial("F02"),cTipo,IIF(cMatriz == "true","S","N"),cRazao,cCNPJ,cRazFor,cCNPJFor,cMesRef,cAnoRef,Val(cVlNotas),Val(cVlDedut)})
			Next nY
		Next nX
    Endif
ElseIf lContinua .And. cTipo == "2" .And. Type( "oXml:_TNS_NAOINFORMACAOVENDAS" ) <> "U"
	If ValType(oXML) == "O" 
		//Verifica se tem mais de uma empresa 
		cIsOBJ 	:= Valtype(OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA)
		nEmp	:= IIF(cIsOBJ == "A",Len(OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA),1)			
		For nX := 1 To nEmp
			//Verifica se tem mais de uma operação
			cIsOBJ 		:= Valtype(OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO)
			nOper		:= IIF(cIsOBJ == "A",Len(OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO),1)
			If Valtype(OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA) == "A"			
				cMatriz 	:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_MATRIZ:TEXT
				cRazao		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_RAZAO_SOCIAL:TEXT
				cCNPJ		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_CNPJ:TEXT		
			Else
				cMatriz 	:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA:_TNS_MATRIZ:TEXT
				cRazao		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA:_TNS_RAZAO_SOCIAL:TEXT
				cCNPJ		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA:_TNS_CNPJ:TEXT
			Endif
			For nY = 1 To nOper
				If ValType(OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO) == "A"
					cRazFor		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_RAZAO_SOCIAL:TEXT
					cCNPJFor	:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_CNPJ:TEXT
					cMesRef		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_MES_REF:TEXT
					cAnoRef		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_ANO_REF:TEXT
					cVlNotas	:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO[nY]:_TNS_VL_TOTAL_NOTA:TEXT
				Else               
					cRazFor		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_RAZAO_SOCIAL:TEXT			
					cCNPJFor	:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_CNPJ:TEXT
					cMesRef		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_MES_REF:TEXT
					cAnoRef		:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_ANO_REF:TEXT
					cVlNotas	:= OXML:_TNS_NAOINFORMACAOVENDAS:_TNS_EMPRESA[nX]:_TNS_OPERACAO:_TNS_VL_TOTAL_NOTA:TEXT
				Endif
			cMesRef := IIF(Len(cMesRef)==1,"0"+cMesRef,cMesRef)
			AADD(aGrava,{xFilial("F02"),cTipo,IIF(cMatriz == "true","S","N"),cRazao,cCNPJ,cRazFor,cCNPJFor,cMesRef,cAnoRef,Val(cVlNotas),Val(cVlDedut)})
			Next nY
		Next nX	
	Endif
Endif
// Gravação
If Len(aGrava)=0
	Aviso("Atenção","Verifique os parâmetros pois o arquivo indicado não possui o layout correspondente ao tipo selecionado.",{"OK"},1)
	lContinua := .F.
Endif
dbSelectArea("F02")
dbSetOrder(1)
If lContinua

	For nG := 1 To Len(aGrava)
		If F02->(MsSeek(xFilial("F02")+aGrava[nG,5]+aGrava[nG,7]+aGrava[nG,8]+aGrava[nG,9]+aGrava[nG,2]))	
			If nOpc == 0
				nOpc := AVISO("Atenção!"," Já existe movimento para. " + Chr(13) + Chr(10) +;
				" Empresa: "   + aGrava[nG,4] + " CNPJ: " + aGrava[nG,5] + Chr(13) + Chr(10) +;
				" Fornecedor: "+ aGrava[nG,6] + " Forn. CNPJ: "+aGrava[nG,7] + Chr(13) + Chr(10) +;
				" Perído: "    + cMesRef      + "/" + cAnoRef +Chr(13) + Chr(10) +;
				" Você deseja?",{"Reimportar","Manter os dados existentes"},1)
				If nOpc = 1
				   Fis74Del(aGrava[nG,5],aGrava[nG,7],aGrava[nG,8],aGrava[nG,9],aGrava[nG,2])
				EndIf
			EndIf
		Else
			nOpc := 3
		EndIf
		If nOpc == 1 .Or. nOpc == 3
			RecLock("F02",.T.)
			F02->F02_FILIAL 	:=	aGrava[nG,1]
			F02->F02_TIPO		:=  aGrava[nG,2]
			F02->F02_MATRIZ		:=	aGrava[nG,3]
			F02->F02_EMPRAS		:=	aGrava[nG,4]
			F02->F02_EMPCGC		:=	aGrava[nG,5]
			F02->F02_FORRAZ		:=	aGrava[nG,6]
			F02->F02_FORCGC		:=	aGrava[nG,7]
			F02->F02_MESREF		:=	aGrava[nG,8]
			F02->F02_ANOREF		:=	aGrava[nG,9]
			F02->F02_VLTOTN		:=	aGrava[nG,10]
			F02->F02_VLDEDU		:=	aGrava[nG,11]
			MsUnLock()
		EndIf
		nOpc := 0
	Next nG
Endif
If lContinua
	FreeObj(oXml)
	MsgInfo("XML importado com sucesso!")
EndIf
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} FIS74DEL
Rotina de exclusão de registros da tabela F02.

@return Nil

@author Cleber Maldonado
@since 06/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fis74Del(cEmpCgc, cForCgc, cMesRef, cAnoRef, cTipo)

Local cQuery	:=  ""//GetNextAlias()

cQuery := "DELETE FROM "+RetSqlName("F02")+ " "
cQuery += "WHERE F02_FILIAL = '"+xFilial("F02") +"' AND "
cQuery += "F02_EMPCGC = '" + cEmpCgc + "' AND "
cQuery += "F02_FORCGC = '" + cForCgc + "' AND "
cQuery += "F02_MESREF = '" + cMesRef + "' AND "
cQuery += "F02_ANOREF = '" + cAnoRef + "' AND "
cQuery += "F02_TIPO = '" + cTipo +"'"
nRet := TcSqlExec(cQuery)
//Até o momento a expressão DELETE não funciona para BeginSql, por isso usei TcSqlExec()
/*BeginSql Alias cQuery
	DELETE %table:F02% F02
	WHERE 	F02.F02_FILIAL = %xfilial:F02% AND
			F02.F02_MESREF = %Exp:cMesRef% AND 
			F02.F02_ANOREF = %Exp:cAnoRef% AND
			F02.F02_TIPO 	 = %Exp:cTipo%
EndSql*/
Return 