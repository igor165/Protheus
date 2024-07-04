#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "Rspa170.ch"
#include "xmlxfun.ch"    

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Rspa170   � Autor � Emerson Grassi Rocha  � Data � 18/04/01   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Importacao de Curriculo atraves de arquivo XML.               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �Rspa170                                                       ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������Ĵ��
���Cecilia Car.�29/07/14�TQENN4  �Incluido o fonte da 11 para a 12 e efetua-���
���            �        �        �da a limpeza.                             ���
���Renan Borges�10/11/14�TQUGT7  �Ajuste para realizar a importa��o do curri��� 
���            �        �        �culo mesmo quando o caminho passada n�o te���
���            �        �        �nha as barras, nesse caso o sistema enten-���
���            �        �        �de que seja um caminho do servidor.       ���    
���Everson SP  �04/12/14�TRCXBV	 �Criada nova chave no SXE e SXF para gerar ��� 
���            �        �		 �a numera��o sequencial da tabela de curri-���
���            �        �		 �culos corretamente.                       ���
���Paulo O     �10/03/17�MRH-7824�Criada verifica��o se o arquivo XML possui��� 
���Inzonha     �        �        �mais de um registro de candidato(SQG).se  ���
���            �        �        �houver apresenta erro no log de importa��o���  
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RSPA170()
Local cDir		:= Alltrim( GETMV("MV_RSPDCUR") )
Local aFiles	:= {}  
Local nXml      := 0
Local lRet		:= .F.
Local nPos		:= 0
Local nPos1		:= 0
Local nPos2		:= 0
Local nPos3		:= 0
Local lLinux	:= IsSrvUnix()

Private aXml 	:= {}
Private oXml   	
Private aArqMain:= {}  

Private aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private aFldRel		:= {"RA_NOME"}
Private lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

//Tratamento de acesso a Dados Sens�veis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return NIL
EndIf
	
If Empty(cDir)
	Aviso(STR0007, STR0008, {"Ok"})	//"Atencao"###"Configure o parametro MV_RSPDCUR, deve conter o diretorio que contem os arquivos XML para Importacao"
	Return Nil
EndIf

nPos1 := AT("\",cDir)+1		//Padrao
nPos2 := AT("/",cDir)+1		//Linux

nPos3 := AT(":",cDir)

nPos := Max(nPos1,nPos2)

If nPos < 4
	cDir := Subs(cDir,nPos,Len(cDir))
EndIf

If nPos3 == 0
	cDir := If(lLinux,"/" +  cDir, "\" + cDir)
EndIf


If ( Subs(cDir,Len(cDir)) <> "/" ).AND. ( Subs(cDir,Len(cDir)) <> "\" )
	If lLinux
		cDir := cDir + "/"
	Else
		cDir := cDir + "\"
	EndIf

EndIf

dbSelectArea("SQH")
dbSetOrder(1)
dbGoTop()
If Eof()
	Help("",1,"RS170VAZIO") // O arquivo de configuracao (SQH) esta vazio.
	Return Nil
EndIf
            
//�������������������������������������������������������
//� Criacao de Objeto contendo Informacoes do Curriculo �
//�������������������������������������������������������
If !Rs170XML(@cDir, @aFiles)
	Return Nil
EndIf
Processa({||Rsp170Proc(aFiles,cDir)},OemToAnsi(STR0028)) //"Aguarde... Importacao de curriculo"

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rsp170Proc� Autor � Emerson Grassi Rocha  � Data � 18/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Processamento dos curriculos                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Rspa170                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Marcos Alves�02/08/06�xxxxxx�Separacao da funcao de processamento, para���
���            �        �      �implementacao da barra de progresso       ���   
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Rsp170Proc(aFiles,cDir)
Local nx		:= 0
Local lAll		:= .F.	//Flag para considerar para todas as respostas do aviso
Local lXml		:= .T.
Local cXml   	:= ""
Local lCamp		:= .T.
Local cErro		:= ""
Local lRs170Rot	:= .T.

Local aLogMsg		:= {}				// Array para armazenar mensagem de falha importacao de curriculos
Private aLogAux		:= {}				// Array para armazenar mensagem de falha importacao de curriculos

//aAdd(aLogAux, STR0029)    //"Erro no arquivo XML"
//aAdd(aLogAux,"")    
//aAdd(aLogAux,STR0030+space(15)+STR0031) //"Arquivo"##"Error"    
ProcRegua( Len(aFiles) )	    
For nX := 1 To Len(aFiles)
	IncProc(STR0032+" "+aXml[nX][1])	//"Importando curriculo.:"
	If aFiles[nX][1]	//Box .T.
		//������������������������������������������������������������������������Ŀ
		//�Verifica se ha XML a processar                                          �
		//��������������������������������������������������������������������������
		If (nXml := FOpen(cDir+aXml[nX][1],16)) < 0
			lXml := .F.
		Else
			lXml := .T.
		EndIf
		//������������������������������������������������������������������������Ŀ
		//�Verifica se ha XML a processar                                          �
		//��������������������������������������������������������������������������
		If lXml
			cXml := FReadStr(nXml,aXml[nX][2])
			oXML := XmlParser( cXML,"_",@cErro,"" )	
			If Empty(cErro)
				If !Rs170Rot(aXml[nX][1],@lAll)	//Importacao do Arquivo		
					lRs170Rot	:= .F.
				EndIf
			Else
			    lCamp := .F.
			EndIf
			If !Empty(cErro) .Or. !lCamp
				If (nPos:=Ascan(aLogAux, {|x| x==STR0030+space(15)+STR0031}))=0 //"Arquivo"##"Error"    
					aAdd(aLogAux, STR0029)    //"Erro no arquivo XML"
					aAdd(aLogAux,"")    
					aAdd(aLogAux,STR0030+space(15)+STR0031) //"Arquivo"##"Error"
					nPos:=4
				Else
                	nPos++
	            EndIf
	            If aLogAux[1] != STR0038
	                aAdd(aLogAux,"")
	      			aIns(aLogAux,nPos)
	                aLogAux[nPos]:=Subs(aXml[nX][1]+space(20),1,20)+"  " + If(Empty(cErro),STR0016,cErro)
	            endIf
			EndIf
			FClose(nXml)
			If nXml > 0 .And. Empty(cErro) .And. lCamp
				Rs170Renom(cDir, Alltrim(aXml[nx][1]))
			EndIf
			oXml := Nil
			DelClassIntF()
		EndIf
	EndIf
Next nX	
//��������������������������������������������������������������������������������������������������Ŀ
//� Exibicao do log de mensagens ao final do processamento quando selecionado a opcao 1-Imprime Log  �
//����������������������������������������������������������������������������������������������������
If Len(aLogAux) > 3 .And. lRs170Rot 
	/*
	�������������������������������������������������������������Ŀ
	� Gera e Mostra o Log 										  �
	���������������������������������������������������������������*/
	FMakeLog( { aLogAux } ,{OemToAnsi( STR0034)}, , NIL , NIL , STR0034,"M","P",,.F. ) //"Log Importacao de Curriculos"
EndIf 
Return Nil
             
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs170Rot  � Autor � Emerson Grassi Rocha  � Data � 12/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina Principal de Importacao.							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Rspa170                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs170Rot(cArqXML,lAll)

Local aCampos 	:= {}
Local lNovo		:= .T.
Local nPosSQG	:= 0
Local nPosCur	:= 0
Local cCmp		:= ""
Local cAlias	:= ""
Local nx		:= 0
Local ny		:= 0
Local aCamp		:= {}
Local nPosCmp	:= 0
Local cCur		:= AllTrim(posicione("SX3", 2, "QG_CURRIC"	, "x3descric()"))
Local cNom		:= AllTrim(posicione("SX3", 2, "QG_NOME"	, "x3descric()"))
Local cRg		:= AllTrim(posicione("SX3", 2, "QG_RG"		, "x3descric()"))
Local cCic		:= AllTrim(posicione("SX3", 2, "QG_CIC"		, "x3descric()"))
Local nOp		:= 9
Local cPathSQG
Local cRetSqlName
Local cContSQG  := 0
Local lRetConf	:= .T.

Static aOpcao	
Static nOpx

Private cCurric	:=""
Default nOpx 	:=0

If !Rs170Camp(cArqXML)          

	dbSelectArea("SQH")
	dbSetOrder(1)
	
	Return .F.
EndIf	

//verica quantos regitros SQG possuem no arquivo. 
For ny = 1 To Len(aArqMain)   

	if aArqMain[ny][1] == "SQG"
		cContSQG += 1 
	endIf
	
Next ny

If cContSQG <= 1
//��������������������������������������������������������
//� Verifica duplicidade de Dados, pelo dados:			 �
//� CIC													 �
//� RG													 �
//� NOME												 �
//��������������������������������������������������������
	dbSelectArea("SQH")
	dbSetOrder(1)
	aCamp 	:= { {"QG_CIC",3,cCic}, {"QG_RG",2,cRg}, {"QG_NOME",5,cNom} }
	For nx := 1 To Len(aCamp) 
		
		If dbSeek(xFilial("SQH")+aCamp[nx][1]) 
		
			nPosSQG := Ascan(aArqMain, {|x| Upper(Alltrim(x[1])) == "SQG"})
			If nPosSQG > 0
				nPosCmp := Ascan(aArqMain[nPosSQG][2][1], {|x| Upper(Alltrim(x[1])) == Upper(AllTrim(SQH->QH_XML))})
				If nPosCmp > 0 .And. !Empty(Alltrim(aArqMain[nPosSQG][2][1][nPosCmp][2]))
					cCmp := Upper(Alltrim(aArqMain[nPosSQG][2][1][nPosCmp][2]))
	
					dbSelectArea("SQG")
					dbSetOrder(aCamp[nx][2])
					If dbSeek(xFilial("SQG")+cCmp)
						If !lAll
							//������������������������������������������������������������������������Ŀ
							//�Apresenta a opcao de inclusao, somente quando for encontrado por Nome   �
							//�CIC e RG, sao chave unicas                                              �
							//��������������������������������������������������������������������������
	                	   	If nX==3
								aOpcao:={STR0018, STR0020, STR0019 } 	//"Abandonar"###"Sobrepor"###"Incluir"
	        	          	Else
								aOpcao:={STR0018, STR0020} 	//"Abandonar"###"Sobrepor"###
						  	EndIf	
							nOpx := AvisoAll(OemToAnsi(STR0007) ,;	//"Atencao"
									cCur+": "+SQG->QG_CURRIC	+CHR(13)+CHR(10)+;
									cNom+": "+SQG->QG_NOME		+CHR(13)+CHR(10)+;
									cRg+": "+SQG->QG_RG			+CHR(13)+CHR(10)+;
									cCic+": "+SQG->QG_CIC	,;
									aOpcao, 2, aCamp[nx][3]+OemToAnsi(STR0021),,,@lAll)  //"ja cadastrado: "
	
	                    EndIf
	                    If (nPos:=Ascan(aLogAux, {|x| x==STR0035+"  - "+aOpcao[nOpx]}))<>0
							aAdd(aLogAux,"")
	      					aIns(aLogAux,nPos+2)
	                        aLogAux[nPos+2]:=SQG->QG_CURRIC+"  "+SQG->QG_NOME+"  "+SQG->QG_RG+"  "+SQG->QG_CIC
						Else
							aAdd(aLogAux, "")    
							aAdd(aLogAux,STR0035+"  - "+aOpcao[nOpx])    //"Curriculos "
							aAdd(aLogAux,Subs(cCur+space(Len(SQG->QG_CURRIC)),1,Len(SQG->QG_CURRIC))+"  "+;
							              Subs(cNom+space(Len(SQG->QG_NOME))  ,1,Len(SQG->QG_NOME))  +"  "+;
							              Subs(cRg +space(Len(SQG->QG_RG))    ,1,Len(SQG->QG_RG))    +"  "+;    
							              Subs(cCic+space(Len(SQG->QG_CIC))   ,1,Len(SQG->QG_CIC))   +"  ")    
		    				aAdd(aLogAux, SQG->QG_CURRIC+"  "+SQG->QG_NOME+"  "+SQG->QG_RG+"  "+SQG->QG_CIC)    
	         			EndIf
						nOp		:= nOpx
						dbSelectArea("SQG")
						dbSetOrder(1)
						cCurric := SQG->QG_CURRIC
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next nx
Else //se houver mais de um registro SQG cancela a importa��o do arquivo.	
	aAdd(aLogAux,STR0038)
	aAdd(aLogAux,cArqXML)
	return .F.
EndIf

If nOp == 0 .Or. nOp == 1    	//Abandona
	Return .T.

ElseIf nOp == 3 .Or. nOp == 9	//Inclui novo curriculo
	//��������������������������������������������������������
	//� Determina numeracao do Curriculo 					 �
	//��������������������������������������������������������
	DbSelectArea("SX2")
	DbSeek('SQG')
	cPathSQG:= SX2->X2_PATH
	cRetSqlName := (Alltrim(cPathSQG)+RetSqlName( "SQG" )+"\3")
	dbSelectArea("SQH")
	dbSetOrder(1)
	dbSeek(xFilial("SQH")+"QG_CURRIC")
	If Eof() .Or. Empty(SQH->QH_XML)
		cCurric := GetSXENum("SQG","QG_CURRIC",xFilial('SQG')+cRetSqlName)  
	Else	// Se for informado conteudo para o codigo do curriculo 
		nPosSQG := Ascan(aArqMain, {|x| Upper(Alltrim(x[1])) == "SQG"})
		If nPosSQG > 0
			nPosCur := Ascan(aArqMain[nPosSQG][2][1], {|x| Upper(Alltrim(x[1])) == Upper(AllTrim(SQH->QH_XML))})
			If nPosCur > 0 .And. !Empty(Alltrim(aArqMain[nPosSQG][2][1][nPosCur][2]))
				cCurric := Upper(Alltrim(aArqMain[nPosSQG][2][1][nPosCur][2]))
			Else
				cCurric := GetSXENum("SQG","QG_CURRIC",xFilial('SQG')+cRetSqlName)  
			EndIf
		EndIf
	EndIf
	
	dbSelectArea("SQG")
	dbSetOrder(1)
	If dbSeek(xFilial("SQG")+cCurric)
		Aviso(STR0007,STR0004+'"'+cCurric+'"',{"OK"}) // "Atencao"###"Ja existe Curriculo gravado com a identificacao "
		lNovo := .F.	
		//��������������������������������������������������������
		//� Pergunta de confirmacao de gravacao de curriculo. 	 �
		//��������������������������������������������������������		
		If !MsgYesNo(STR0003,cCurric) // "Confirma gravacao do Curriculo? "
			If __lSX8
				RollBackSX8()
			EndIf  
			Return .F.
		EndIf
	EndIf
ElseIf nOp == 2				//Sobrepoe curriculo
	lNovo := .F.
EndIf

Begin Transaction
	For nX := 1 To Len(aArqMain)	//Alias
		aCampos := Aclone(aArqMain[nX])
        cAlias	:= aCampos[1]
        // Criacao de Chave          
		If Left(cAlias,1) == "S"
			cCmp := cAlias+"->"+Subst(cAlias,2,2)+"_"
		Else
			cCmp := cAlias+"->"+cAlias+"_"			
		EndIf
		cChave := cCmp+"FILIAL+"+cCmp+"CURRIC"
		// Apaga registros do curriculo antes de gravar
		If !lNovo .And. cAlias != "SQG"
			dbSelectArea(cAlias)
			dbSetOrder(1)
			dbSeek(xFilial(cAlias)+cCurric)
			While !Eof() .And. (xFilial(cAlias)+cCurric) == &cChave
				RecLock(cAlias, .F.)
				dbDelete()
				(cAlias)->( MsUnlock() )    
				dbSkip()
			EndDo               
		EndIf
		// Grava Arquivo			
		lRetConf:= Rs170Grava(aCampos,lNovo, cAlias, cCmp)  
		If !lRetConf
			DisarmTransaction()
			Break
		EndIf
    Next nX  
End Transaction

If __lSX8
	ConfirmSX8()
EndIf

dbSelectArea("SQH")
dbSetOrder(1)

Return lRetConf
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs170Camp � Autor � Emerson Grassi Rocha  � Data � 18/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta arquivo com os campos do Curriculo(XML).			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Rspa170                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs170Camp(cArqXML)
       
Local nA		:= 0
Local nB		:= 0
Local nI 		:= 0
Local lRet 		:= .T.
Local lOk 		:= .F.
Local aObj_Xml	:= {}
Local aCampos	:= {}

//Verifica estrutura do arquivo XML
aObj_Xml:= ClassDataArr(oXml)
If Ascan(aObj_Xml,{|x| Upper(x[1]) == "_MODULEDATA" }) > 0
	aObj_Xml := ClassDataArr(oXml:_Moduledata)
	If Ascan(aObj_Xml,{|x| Upper(x[1]) == "_ENTITY" }) > 0
		aObj_Xml := ClassDataArr(oXml:_Moduledata:_entity)
		If Ascan(aObj_Xml,{|x| Upper(x[1]) == "_SIGAFILES" }) > 0
	 		lOk := .T.
        EndIf
	EndIf
EndIf
aObj_Xml := {}
	
If !lOk 
	Aviso( STR0007, STR0016, {"Ok"}, , cArqXML )	//"Atencao"###'O arquivo XML deve possuir estrutura "MODULEDATA", "ENTITY" e "SIGAFILES".'
	Return .F.
EndIf             

aArqMain := {}
If ValType(oXML:_MODULEDATA:_ENTITY:_SIGAFILES) == "O"	//Objeto

	cArq := oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_TEXT:TEXT
	
	If ValType(oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS) == "O"	//Objeto
		aCampos := {}
		aArq := {}
		For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS:_ATTRIBUTE)	//Array dos Dados
			Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;	// Nome Campo
									oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS:_ATTRIBUTE[nI]:TEXT})            	// Conteudo	 
		Next nI							
		Aadd(aArq, aCampos)
	Else																//Array
		aArq := {}
		For nB := 1 To Len(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS )
			aCampos := {}
			For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS[nB]:_ATTRIBUTE)	//Array dos Dados
				Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS[nB]:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;	// Nome Campo
										oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS[nB]:_ATTRIBUTE[nI]:TEXT}) 	         	// Conteudo
			Next nI 
			Aadd(aArq, aCampos)
		Next nB
			
	EndIf
	Aadd(aArqMain, {cArq, aArq})

Else 

	For nA := 1 To Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES) 	//Array dos Arquivos
		cArq := oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_TEXT:TEXT
		
		If ValType(oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS) == "O"	//Objeto
			aCampos := {}
			aArq := {}
			For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS:_ATTRIBUTE)	//Array dos Dados
				Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;	// Nome Campo
										oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS:_ATTRIBUTE[nI]:TEXT})            	// Conteudo	 
			Next nI							
			Aadd(aArq, aCampos)
		Else																//Array
			aArq := {}
			For nB := 1 To Len(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS )
				aCampos := {}
				For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS[nB]:_ATTRIBUTE)	//Array dos Dados
					Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS[nB]:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;	// Nome Campo
											oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS[nB]:_ATTRIBUTE[nI]:TEXT}) 	         	// Conteudo
				Next nI 
				Aadd(aArq, aCampos)
			Next nB
				
		EndIf
		Aadd(aArqMain, {cArq, aArq})
	Next nA
	
EndIf
	             
Return(lRet)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs170Grava� Autor � Emerson Grassi Rocha  � Data � 18/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Grava os registros referente ao treinamentos                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�aCamp	 : Array com campos a serem gravados no Cad.Curriculo.���
���			 �lNovo  : T - Cria Registro. 		F - Sobrepoe Registro.	  ���
���			 �cAlias : Alias do Arquivo a ser gravado.					  ���
���			 �cCmp	 : Retorna identificao de Alias e Prefixo do Arquivo. ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �RSPA170                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs170Grava(aCamp, lNovo, cAlias, cCmp)

Local cCampo 	:= ""	// Nome do Campo XML   
Local cValor 	:= ""	// Conteudo do Campo XML
Local cCpoChv	:= ""	// Campo Chave para gravacao MSMM
Local nI		:= 0	// Numero do Item do Array
Local aCmpQH 	:= {}  // Campos do arquivo de Configuracao
Local aMemo		:= {}	// Campos Memo do Arquivo de Config.
Local nX		:= 0 
Local aCampos	:= {}
Local cCmp1		:= Right(cCmp,3)
Local cCmp2		:= ""
Local nTpTrab	:= 0
Local nTpExper	:= 0
Local nAno		:= 0
Local dAdmissao	:= dDemissao := CtoD("")
Local cArea		:= ""  
Local cCpoErro	:= ""
Local lExit		:= .F.
Local lRet		:= .T.

default cCurric	:=""			

For nX := 1 To Len(aCamp[2])
   	aCampos := Aclone(aCamp[2][nX])
	/*/
	��������������������������������������������������������������Ŀ
	� Cria as Variaveis de Memoria e Carrega os Dados              �
	����������������������������������������������������������������/*/
	For nI := 1 To Len(aCampos)
		SetMemVar( aCampos[nI][1] , aCampos[nI][2], .T. )
	Next nLoop
   	
	dbSelectArea("SQH")
	dbSetOrder(1)
	dbSeek(xFilial("SQH")+cCmp1)
	While !Eof() .And. cCmp1 == Left(SQH->QH_CAMPO,3)        
	    //��������������������������������������������������������������Ŀ
		//� Verifica se a Importacao do Curriculo sera efetivada ou nao. �
	   	//����������������������������������������������������������������	 
	    If lExit
	    	Aviso(STR0007,STR0023,{"Ok"} )	//"Atencao"#"Importacao nao realizada!"
	    	Return .F.
    	EndIf	
		cCampo := Alltrim(SQH->QH_XML)                    
		If !Empty(cCampo) .Or. "_CURRIC" $ Alltrim(SQH->QH_CAMPO)
			
			cCmp2 	:= cCmp+Alltrim(Subs(SQH->QH_CAMPO,4,20))

			nI := Ascan(aCampos,{|x| Alltrim(x[1]) == cCampo })
			If nI > 0 
				cValor 	:= aCampos[nI][2]
			Else 
			    cValor  := cCampo
			Endif	
			
			If Left(SQH->QH_XML,1) == "#"	//Formula
				cCpoErro:= Alltrim(SQH->QH_CAMPO)  
				lExit	:= Rs170Form(@cValor,cCpoErro,SQH->QH_XML)
			Else	
				If SQH->QH_TIPO == "N"
					cValor := Val(cValor)
				ElseIf SQH->QH_TIPO == "D"
					cValor := Ctod(cValor)
				EndIf
			EndIf
						
			If ! cCmp2 $("SQG->QG_ANALISE,SQG->QG_EXPER,SQL->QL_ATIVIDA") 
			
				If "_CURRIC" $ cCmp2	// Verifica se eh Codigo Curric.
					cValor := cCurric				
				EndIf
				Aadd(aCmpQH,{cCmp2 ,cValor })
			Else
				Aadd(aMemo,{cCmp2, cValor })
			EndIf
				
		EndIf
		
		dbSelectArea("SQH")
		dbSkip()
	End 
	
	//������������������������������������������������������Ŀ
	//� Gravacao dos Dados do Curriculo						 �
	//��������������������������������������������������������
	dbSelectArea(cAlias)
	dbSetOrder(1)     
	If Len(aCmpQH) > 0                

		If cAlias == "SQG"
			RecLock(cAlias,lNovo)
			&(cCmp+"FILIAL") 	:= xFilial(cAlias)   		
			&(cCmp+"CURRIC")	:= cCurric     
		Else 
			RecLock(cAlias,.T.)
			&(cCmp+"FILIAL") 	:= xFilial(cAlias)   		
			&(cCmp+"CURRIC")	:= cCurric   
		EndIf
	              
		Aeval(aCmpQH,{|x| If(ValType(&(x[1])) == ValType(x[2]),;
		(&(x[1]) := (If(ValType(x[2]) == "C", Upper(x[2]), x[2]))),) })
	EndIf
	
	(cAlias)->(MsUnlock())
	
	For nI := 1 to Len(aMemo)   
		cCpoChv := Subs(aMemo[nI][1],6,Len(aMemo[nI][1])-5)
		MSMM(&cCpoChv,,,aMemo[nI][2],1,,,cAlias,cCpoChv)
	Next nI    
	
	aMemo := {}
			
	dbSelectArea("SQH")
	dbSetOrder(1)
Next nX   

//����������������������������������������������������������������Ŀ
//� Gravacao do Tempo de Trabalho e do Tempo de Experiencia no SQG �
//������������������������������������������������������������������
DbSelectArea("SQG")
DbSetOrder(1)
cArea := SQG->QG_AREA

If SQG->QG_TPTRAB == 0	//Tempo Trabalhado

	DbSelectArea("SQL")       
	DbSetOrder(1)
	dbSeek(xFilial("SQL")+cCurric)
	
	While !SQL->(Eof()) .And. xFilial("SQL")+SQL->QL_CURRIC == xFilial("SQG")+cCurric
		   
		If !Empty(SQL->QL_DTADMIS)
			dDemissao	:= SQL->QL_DTDEMIS
			dAdmissao	:= SQL->QL_DTADMIS
			If Empty(SQL->QL_DTADMIS)
				dDemissao := dDatabase		
			EndIf  
			nAno	:= 	(dDemissao - dAdmissao) / 365
			If	SQL->QL_AREA == cArea 
				nTpExper += nAno
			EndIf
			nTpTrab+= nAno				
		EndIf
	   If nTpTrab<0.OR.Len(Alltrim(Str(nTpTrab)))>TamSx3("QG_TPTRAB")[1]
	   		nTpTrab:=0
	   EndIf		
	   If nTpExper<0.OR.Len(Alltrim(Str(nTpExper)))>TamSx3("QG_TPTRAB")[1]
	   		nTpExper:=0
	   EndIf		
	    SQG->( RecLock("SQG",.F.) )
			Replace SQG->QG_TPTRAB 	With nTpTrab
			Replace SQG->QG_TPEXPER With nTpExper
		SQG->( MsUnlock() )    
	    SQL->(dbSkip())
	EndDo  

EndIf	

	// PONTO DE ENTRADA PARA VALIDAR OS CAMPOS DA ABA EXTRACURRICULARES.
	If lRet .And. ExistBlock("PA170TOK")
		lRet := ExecBlock("PA170TOK", .F., .F., {aCampos})
	EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs170Renom� Autor � Emerson Grassi Rocha  � Data � 12/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Renomeia arquivo XML ja importado.			              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cArquivo: Arquivo a ser renomeado							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �RSPA170                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs170Renom(cDir, cArquivo)

Local cArqBkp	:= ""
Local cArqXML	:= cDir+cArquivo 

//Cria backup do arquivo
cArqBkp := StrTran(cArqXml,".XML",".XM#")

// Deleta o backup anterior (se houver)
MSErase(cArqBkp)

// Renomeia Arquivo ja importado
If Frename(cArqXml,cArqBkp) != 0
	Aviso(STR0007, STR0009+cArquivo, {"Ok"})	//"Aviso"###"Nao foi possivel renomear arquivo "
EndIf  

Return 			

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs170XML  � Autor � Emerson Grassi Rocha  � Data � 12/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria Objeto / array de arquivo XML 			              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �RSPA170                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs170XML(cDir, aArquivos)

Local oLstXml
Local lRet		:= .T.

Local oOk 		:= LoadBitmap( GetResources(), "Enable" )
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )

//��������������������������������Ŀ
//� Variaveis de Teclas de Atalho. �
//����������������������������������
Local bNIL			:= { || NIL }
Local bSvVK_F4		:= bNIL
Local bSvVK_F5		:= bNIL
Local bSvVK_F6		:= bNIL

//��������������������������������Ŀ
//� Variaveis de Botoes  		   �
//����������������������������������                    
Local oBtnMarcTod
Local oBtnDesmTod
Local oBtnInverte
               
Local l1Elem		:= .F.
Local nElemRet		:= 4096
Local lMultSelect 	:= .T.
Local bSet15
Local bSet24
Local aButtons := {}

//��������������������������������������������������������������Ŀ
//� Declara��o de arrays para dimensionar tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 70	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 70	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*40), (((aObjSize[1,4])/100)*68) }	//1,3 Vertical /1,4 Horizontal

aXml		:=	Directory(cDir+ "\*.XML")
Processa({||aArquivos:=RSP170Curric(cDir)},OemToAnsi(STR0036)) //"Aguarde... listando curriculos"
If Len(aArquivos) == 0
	Aviso(STR0007, STR0010 + " "+ cDir, {"Ok"}) //"Atencao"###"N�o existem curr�culos no formato XML para Importa��o no diret�rio:"
	Return .F.
EndIf

l1Elem		:= .F.
nElemRet	:= 4096
lMultSelect := .T.

SETAPILHA()
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0011) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL OF oMainWnd //"Selecao Arquivos"
    
	@ aGdCoord[1],aGdCoord[2] LISTBOX oLstXml FIELDS HEADER " ", OemtoAnsi(STR0012) OF oDlg PIXEL SIZE aGdCoord[4],aGdCoord[3]; //"Arquivos"
	ON CHANGE (nPesq:=oLstXml:nAt) ON DBLCLICK (aArquivos[oLstXml:nAt,1] := !aArquivos[oLstXml:nAt,1], oLstXml:Refresh(.f.))
	oLstXml:SetArray(aArquivos)
  	oLstXml:bLine := { ||{	If(aArquivos[oLstXml:nAt,1],oOk,oNo),;
  							aArquivos[oLstXml:nAt,2] }}
	oLstXml:nFreeze := 1  							  							

	@ (((aObjSize[1,3])/100)*50),aGdCoord[2] BUTTON oBtnMarcTod	PROMPT OemToAnsi( STR0013 )		SIZE 70,13.50 OF oDlg	PIXEL ACTION (aArquivos:=RspTrocaMarca(oLstXml:nAt,aArquivos,l1Elem,nElemRet,lMultSelect,"M"),oLstXml:nColPos := 1,oLstXml:Refresh()) //"Marca Todos - <F4>"
	bSvVK_F4 := SetKey(VK_F4,{ || (aArquivos:=RspTrocaMarca(oLstXml:nAt,aArquivos,l1Elem,nElemRet,lMultSelect,"M"),oLstXml:nColPos := 1,oLstXml:Refresh()) } )
	@ (((aObjSize[1,3])/100)*50),aGdCoord[2]+90 BUTTON oBtnDesmTod	PROMPT OemToAnsi( STR0014 )		SIZE 70,13.50 OF oDlg	PIXEL ACTION (aArquivos:=RspTrocaMarca(oLstXml:nAt,aArquivos,l1Elem,nElemRet,lMultSelect,"D"),oLstXml:nColPos := 1,oLstXml:Refresh()) //"Desmarca Todos - <F5>"
	bSvVK_F6 := SetKey(VK_F5,{ || (aArquivos:=RspTrocaMarca(oLstXml:nAt,aArquivos,l1Elem,nElemRet,lMultSelect,"D"),oLstXml:nColPos := 1,oLstXml:Refresh()) } )
	@ (((aObjSize[1,3])/100)*50),aGdCoord[2]+180 BUTTON oBtnInverte	PROMPT OemToAnsi( STR0015 ) 	SIZE 70,13.50 OF oDlg	PIXEL ACTION (aArquivos:=RspTrocaMarca(oLstXml:nAt,aArquivos,l1Elem,nElemRet,lMultSelect,"I"),oLstXml:nColPos := 1,oLstXml:Refresh()) //"Inverte Sele��o - <F6>"
	bSvVK_F6 := SetKey(VK_F6,{ || (aArquivos:=RspTrocaMarca(oLstXml:nAt,aArquivos,l1Elem,nElemRet,lMultSelect,"I"),oLstXml:nColPos := 1,oLstXml:Refresh()) } )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lRet:= .T., oDlg:End()  },{|| lRet:=.F. ,oDlg:End()} ) CENTERED
SetaPilha()

SetKey( VK_F4	,	IF( Empty( bSvVK_F4 ) , bNIL , bSvVK_F4 ) )
SetKey( VK_F5	,	IF( Empty( bSvVK_F5 ) , bNIL , bSvVK_F5 ) )
SetKey( VK_F6	,	IF( Empty( bSvVK_F6 ) , bNIL , bSvVK_F6 ) )

DeleteObject(oOk)
DeleteObject(oNo)

If ! lRet
	Return .F.
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RspTrocaMarca  �Autor�Emerson Grassi     � Data � 15/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Efetua a Troca da Selecao no ListBox 			              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Generico	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RspTrocaMarca(	nAt			,;	//Indice do ListBox de f_Opcoes()
						aArray		,;	//Array do ListBox de f_Opcoes()	
						l1Elem		,;	//Se Selecao apenas de 1 elemento
						nElemRet	,;	//Posicao do Elemento de Retorno
						lMultSelect	,;	//Se Trata Multipla Selecao
						cTipo		 ;	//Tipo da Multipla Selecao "M"arca Todos; "D"esmarca Todos; "I"nverte Selecao
						   )

Local aAuxil	:= {}
Local nTrue 	:= 0.00
Local nArray	:= Len( aArray )
Local nX		:= 0.00

DEFAULT nAt			:= 1.00
DEFAULT aArray		:= {}
DEFAULT l1Elem		:= .F.
DEFAULT nElemRet	:= 0.00
DEFAULT lMultSelect := .F.
DEFAULT cTipo		:= "I"

IF !Empty( aArray )
	IF !l1Elem
		IF !lMultSelect
			aAdd( aAuxil , { aArray[nAt,1] } )
			aArray[nAt,1] := !aArray[nAt,1]
		ElseIF lMultSelect
			IF cTipo == "M"
				aEval( aArray , { |x,y| aArray[y,1] := If (y <= nElemRet ,.T.,.F.) } )
			ElseIF cTipo == "D"
				aEval( aArray , { |x,y| aArray[y,1] := .F. } )
			ElseIF cTipo == "I"
				aEval( aArray , { |x,y| aArray[y,1] := !aArray[y,1] } )
			EndIF
		EndIF	
		For nX := 1 To nArray
			nTrue := IF( aArray[nX,1] , ++nTrue , nTrue )
		Next nX
		IF nTrue > 0 .and. !lMultSelect
			IF aAuxil[1,1] .and. !aArray[nAt,1]
				nTrue--
			EndIF
		EndIF
		IF nTrue > nElemRet
			aArray[nAt,1] := .F.
            MsgInfo(STR0037+ Str(nElemRet,6)) //"Limite maximo de curriculo excedido" 
			//Help(" " , 1,"GPEMAXIMO")// Limite maximo de elementos no array  excedido 
		EndIF
	Else
		For nX := 1 To nArray
			IF nX == nAt
				aArray[nAt,1]	:= .T.
			Else
				aArray[nX,1]	:= .F. 
			EndIF
		Next nX
	EndIF
EndIF

Return( aArray )

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs170Form � Autor � Eduardo Ju            � Data � 21/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Validacao de Erro.							      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Rspa170                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Rs170Form(cValor,cCpoErro,cCmpFunc)
Local lRet	:= .T.

bErro	:= ErrorBlock({|e| lRet	:= Rs170Erro(e,cCpoErro,cCmpFunc)})

Begin Sequence
	If Type(Subst(cValor,2)) == "U"
		cValor := ""
	Else
		cValor := &(Subst(cValor,2))
	EndIf 
End Sequence		

ErrorBlock(bErro)

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs170Erro � Autor � Eduardo Ju            � Data � 21/12/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Mensagem de Erro.	                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Rspa170                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/      
Static Function Rs170Erro(oError,cCpoErro,cCmpFunc)
Local lRet	:=.T.
Local nOp	:= 0
Local cMsg	:=	STR0024+" : "+cCpoErro+Chr(13)+chr(10)+;
				STR0025+" : "+cCmpFunc+Chr(13)+chr(10)+;
				oError:Description+Chr(13)+chr(10)      
				//"Campo"#"Fun��o

If oError:gencode > 0 
	//Nao = Para a Importacao
	nOp:=Aviso(STR0007,cMsg,{"OK"},,STR0026) //"Atencao"#"Erro na Fun��o"
	Break
EndIf	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP170Curric �Rev.  � Marcos Alves        � Data � 02/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Prepara array com o nome dos arquivos XML, para listbox     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RSP170Curric(cDir)
Local aArquivos	:= {}
Local nX		:= 0 
//������������������������������������������������������������������������Ŀ
//�Verifica se ha XML a processar                                          �
//��������������������������������������������������������������������������
ProcRegua( Len(aXml) )	    
For nX := 1 To Len(aXml)
	IncProc()	
	Aadd( aArquivos, {.F., aXml[nX][1]} )
Next Nx
Return aArquivos

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Aviso        �Rev.  � Edson Maricate      � Data � 04/08/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Janela de aviso com botoes                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �nOpc:Aviso(cCaption,cMensagem,aBotoes)                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �nOpc       :Retorno numerico de acordo botao escolhido      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCaption   :Titulo da Janela                                ���
���          �cMensagem  :Texto da Janela (400 caracteres)                ���
���          �aBotoes    :Array com titulo dos botoes  ( Max.5 )          ���
���          �cCaption2  :Titulo da Descricao (Dentro da Janela)-opcional.���
���          �nRotAutDefault:Retorno DEFAULT assumido em ROT. AUTOMATICA  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static FUNCTION AvisoAll(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,lAll)
 
Local ny        := 0
Local nx        := 0
Local aSize  := {  {134,304,35,155,35,113,51},;  // Tamanho 1
 {134,450,35,155,35,185,51},; // Tamanho 2
 {227,450,35,210,65,185,99} } // Tamanho 3
Local nLinha    := 0
Local cMsgButton:= ""
Local oGet
Local oGet01
//��������������������������������������������������������������Ŀ
//� Declara��o de arrays para dimensionar tela		                         �
//����������������������������������������������������������������
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private oDlgAviso
Private nOpcAviso := 0
 
cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)
 
//��������������������������������������������������������������Ŀ
//� Quando for rotina automatica, envia o aviso ao Log.          �
//����������������������������������������������������������������
If Type('lMsHelpAuto') == 'U'
 lMsHelpAuto := .F.
EndIf
 
If !lMsHelpAuto
 If nSize == Nil
  //��������������������������������������������������������������Ŀ
  //� Verifica o numero de botoes Max. 5 e o tamanho da Msg.       �
  //����������������������������������������������������������������
  If  Len(aBotoes) > 3
   If Len(cMensagem) > 286
    nSize := 3
   Else
    nSize := 2
   EndIf
  Else
   Do Case
   Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
    nSize := 2
   Case Len(cMensagem) >= 250
    nSize := 3
   OtherWise
    nSize := 1
   EndCase
  EndIf
 EndIf
 If nSize <= 3
  nLinha := nSize
 Else
  nLinha := 3
 EndIf
 /*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]-12), (aObjSize[1,2]), (((aObjSize[1,3])/100)*50), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal


 DEFINE MSDIALOG oDlgAviso FROM aAdvSize[7]-17,0 TO aSize[nLinha][1],aSize[nLinha][2] TITLE cCaption Of oMainWnd PIXEL
 DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
 @ aGdCoord[1], aGdCoord[2] BITMAP RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL
 @ aGdCoord[1]+11 ,aGdCoord[2]+35  TO aGdCoord[1]+13 ,aGdCoord[2]+400 LABEL '' OF oDlgAviso PIXEL
 If cBitmap <> Nil
  @ aGdCoord[1]+2, aGdCoord[2]+37 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
  @ aGdCoord[1]+3  ,aGdCoord[2]+50  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold 
 Else
  @ aGdCoord[1]+3  ,aGdCoord[2]+37  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold 
 EndIf
 If nSize <= 3
  @ aGdCoord[1]+16 ,aGdCoord[2]+38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
 Else
  @ aGdCoord[1]+16 ,aGdCoord[2]+38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
 EndIf
 TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
 ny := (aSize[nLinha][2]/2)-36
 For nx:=1 to Len(aBotoes)
  cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
  bAction:=&(cAction)
  cMsgButton:= OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1]))
  cMsgButton:= IF( ( "&" $ SubStr( cMsgButton , 1 , 1 ) ) , cMsgButton , ( "&"+cMsgButton ) )
  TButton():New(aSize[nLinha][7]-3,ny,cMsgButton, oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
  ny -= 35
 Next nx

 @ aSize[nLinha][7]+8,ny+35 CHECKBOX oGet01  VAR lAll    PROMPT OemToAnsi(STR0027) PIXEL OF oDlgAviso SIZE 80,9 //"Repete para todos"

 ACTIVATE MSDIALOG oDlgAviso CENTERED
Else
 If ValType(nRotAutDefault) == "N" .And. nRotAutDefault <= Len(aBotoes)
  cMensagem += " " + aBotoes[nRotAutDefault]
  nOpcAviso := nRotAutDefault
 Endif 
 ConOut(Repl("*",40))
 ConOut(cCaption)
 ConOut(cMensagem)
 ConOut(Repl("*",40))
 AutoGrLog(cCaption)
 AutoGrLog(cMensagem)
EndIf
 
Return (nOpcAviso)
