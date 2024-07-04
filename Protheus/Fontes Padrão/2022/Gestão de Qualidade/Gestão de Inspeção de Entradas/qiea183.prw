#INCLUDE "TOTVS.CH"
#INCLUDE "QIEA183.CH"
#INCLUDE "PROTHEUS.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� FUNCAO   � QIEA183  � AUTOR � Paulo Emidio de Barros� DATA � 29/05/2001 ���
���������������������������������������������������������������������������Ĵ��
��� DESCRICAO� Importacao/Reimportacao das Entradas						    ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAQIE                                                      ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �											���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/                                                                          

Static Function MenuDef(cAlias)

Local aRotina := {}

If cAlias == "TMP"
	Aadd(aRotina,{OemToAnsi(STR0005), "Q183MkAllI()", 0, 5})//"Seleciona"
	Aadd(aRotina,{OemToAnsi(STR0008), "Q183GrvImp()", 0, 5})//"Importacao"
Else                                                                       
	Aadd(aRotina,{OemToAnsi(STR0007), "Q183MkAllQ()", 0, 5})//"Seleciona"
	Aadd(aRotina,{OemToAnsi(STR0008), "Q183GrvImp()", 0, 5})//"Importacao"
	Aadd(aRotina,{OemToAnsi(STR0009), "Q183ExcImp()", 0, 5})//"Exclusao"
EndIf          
Aadd(aRotina,{OemToAnsi(STR0010), "Q183Ocor()" , 0, 3}) //"Ocorrencias"  
Aadd(aRotina,{OemToAnsi(STR0067), "Q183Ficha()", 0, 3}) //Ficha Produto 
Aadd(aRotina,{OemToAnsi(STR0011), "Q183Legend" , 0, 5,,.F.}) //"Legenda"

Return aRotina


Function Qiea183()
Local oTempTable	:= NIL
Local aStru
Local aTam 
Local lContinua
Local cFuncao	:= "QIEA183"
Local cPergunte	:= "QEA183"	
Local cTitulo	:= OemToAnsi( STR0002 )		//"Realizando carga no Arquivo Temporario"
Local cDescricao:= ""
Local bProcessa	:= { |oSelf| Q183GeraTmp("TMP",cFileTmp,aStruTXT,oSelf) }

Private cFileTmp
Private aStruTxt := {}
Private aCpoUsu  := {}

//��������������������������������������������������������������Ŀ
//� mv_par01 = Realiza Importacao         ?  1) Normal  2)TXT    �
//� mv_par02 = Caminho do Arquivo TXT     ?						 �
//� mv_par03 = Arquivo TXT a ser Importado?						 �
//� mv_par04 = Exibe Log de Importacao    ?						 �
//� mv_par05 = Imprime Ocorrencias 		  ?						 �
//����������������������������������������������������������������
lContinua := Pergunte("QEA183",.T.)
cFileTmp  := (AllTrim(mv_par02)+AllTrim(mv_par03))

If mv_par01 == 2
	If File(cFileTmp) == .F.
		lContinua := .F.
	EndIf                    
EndIf

If lContinua
	MsgRun(STR0064,STR0065,{||Q183DelFic()})
Else
	Return(NIL)
EndIf

If (TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] <> TamSx3("QEL_NISERI")[1] .OR.;
    TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] <> TamSx3("QER_NISERI")[1] .OR.;
 	TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] <> TamSx3("QER_NISERI")[1] .OR.;
 	TamSx3("D1_DOC")[1]+TamSx3("D1_SERIE")[1]+ TamSx3("D1_ITEM")[1] <> TamSx3("QEL_NISERI")[1])
	Help(" ",1,"QIENISERI")
	Return Nil
EndIf
//��������������������������������������������������������������Ŀ
//� Realiza a Importacao do arquivo TXT							 �
//����������������������������������������������������������������
If mv_par01 == 2                    

	//��������������������������������������������������������������Ŀ
	//� Retorna a Estrutura do layout para a Importacao TXT			 �
	//����������������������������������������������������������������
	aStruTXT := Q183OpenTxt()

	//��������������������������������������������������������������Ŀ
	//� Define a estrutura do arquivo temporario					 �
	//����������������������������������������������������������������
	aStru := {}
	Aeval(aStruTXT,{|x|aTam := TamSX3(x[3]),Aadd(aStru,{x[3],"C",aTam[1],aTam[2]})})

	//Adiciona os demais campos na estrutura
	aTam := TamSX3("QEP_TES")   ; Aadd(aStru,{"QEP_TES"   ,"C",aTam[1],aTam[2]})
	aTam := TamSX3("QEP_CODTAB"); Aadd(aStru,{"QEP_CODTAB","C",aTam[1],aTam[2]})
	aTam := TamSX3("QEP_LOTORI"); Aadd(aStru,{"QEP_LOTORI","C",aTam[1],aTam[2]})
	aTam := TamSX3("QEP_OK")    ; Aadd(aStru,{"QEP_OK"    ,"C",aTam[1],aTam[2]})
	
	//��������������������������������������������������������������Ŀ
	//� Abre o arquivo Temporario									 �
	//����������������������������������������������������������������
	oTempTable := FWTemporaryTable():New( "TMP" )
	oTempTable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"QEP_FORNEC","QEP_LOJFOR","QEP_PRODUT","QEP_DTENTR","QEP_LOTE"} )
	oTempTable:Create()
	
    dbSelectArea("TMP")
   	
	//��������������������������������������������������������������Ŀ
	//� Executa a gravacao do Arquivo Temporario					 �
	//����������������������������������������������������������������

	Processa({||Q183GeraTmp("TMP",cFileTmp,aStruTXT)},STR0002,; //"Realizando carga no Arquivo Temporario"
	OemToAnsi(STR0003),.F.)//"Gravando Registro..."
	
   	//��������������������������������������������������������������Ŀ
	//� Verifica se o Arquivo esta vazio							 �
	//����������������������������������������������������������������
	dbSelectArea("TMP") 
	dbGoTop()
	If Eof()
   	   Help("  ",1,"QNAOEXITXT") 
   	Else   
		//��������������������������������������������������������������Ŀ
		//� Exibe o Browse com os dados a serem importados				 �
		//����������������������������������������������������������������
		If mv_par04 == 1                  
		   Q183BrwOcor("TMP")                                         
		Else                        
			//��������������������������������������������������������������Ŀ
			//� Realiza a Importacao dos dados sem exibicao do Log			 �
			//����������������������������������������������������������������
			Q183GrvImp(.F.)                                       	                                                            
			
			//��������������������������������������������������������������Ŀ
			//� Realiza a Impressao do Relatorio de Ocorrencias				 �
			//����������������������������������������������������������������
			If mv_par05 == 1			
				Q183Ocor()
			EndIf	
		EndIf
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Exclui o arquivo Temporario									 �
	//����������������������������������������������������������������
	oTempTable:Delete()
	
Else

	//��������������������������������������������������������������Ŀ
	//� Realiza a Importacao do arquivo Normal (a partir do QEP)	 �
	//����������������������������������������������������������������
     
	//Verifica se existem Entradas inconsistentes	
	QEP->(dbSetOrder(1))
	If QEP->(MsSeek(xFilial("QEP")+"2"))
		If QEP->(Eof())
	   	   Help("  ",1,"QNAOEXIINC") 
	   	Else   
			If mv_par04 == 1                  
			   Q183BrwOcor("QEP")                                         
			Else                        
				//��������������������������������������������������������������Ŀ
				//� Realiza a Importacao dos dados sem exibicao do Log			 �
				//����������������������������������������������������������������
				Q183GrvImp(.F.)                                       	
			                                          
			EndIf
		EndIf     
	Endif
	
EndIf

Return(NIL)                                          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183GeraTmp� Autor �Paulo Emidio de Barros� Data �29/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao das Entradas a serem importadas no TMP  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183GeraTmp(EXPC1,EXPC2,EXPN1,EXPA1)						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Alias do Arquivo Temporario						  ���
���          � EXPC2 = Nome do Arquivo Temporario						  ���
���          � EXPA1 = Estrutura do arquivo temporario					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q183GeraTmp(cAlias,cFileTmp,aStruTXT,oSelf)
Local nHandle
Local xBuffer := ""
Local cCampo
Local nQtdRec := 1                
Local bRegua  
Local nCont	  := 0

dbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Grava os dados no arquivo temporario a partir do TXT		 �
//����������������������������������������������������������������
bRegua := {||nHandle := fOpen(cFileTmp,2+64),nQtdRec := fSeek(nHandle,0,2),;       
	fReadLn(nHandle,@xBuffer,1000),nQtdRec := (nQtdRec/Len(xBuffer)),fClose(nHandle)}
Eval(bRegua)

xBuffer := " "
nHandle := fOpen(cFileTmp,2+64)

ProcRegua(nQtdRec)                

While fReadLn(nHandle,@xBuffer,1000) 
	RecLock(cAlias,.T.)
	Aeval(aStruTXT,{|x|cCampo:=SubStr(xBuffer,x[1],(x[2]-x[1])+1),;
		FieldPut(FieldPos(AllTrim(x[3])),cCampo)})
	MsUnLock()
	IncProc()
EndDo

//Fecha o arquivo 
fClose(nHandle)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183BrwOcor� Autor �Paulo Emidio de Barros� Data �30/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibicao do browse com os dados a serem importados		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183BrwOcor(EXPC1)										  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do Arquivo Temporario						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q183BrwOcor(cAlias)
Local aCpoBrw := {}
Local cFilInc := ''
Local nY      := 0
Local cCampo  := ""
local oBrw

//��������������������������������������������������������������Ŀ
//� Define as variaveis utilizadas no MarkBrowse				 �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0004) //"Log de Importacao/Reimportacao" 
Private cMarca    := GetMark() 
Private lInverte
                                                                           
//��������������������������������������������������������������Ŀ
//� Monta o aRotina conforme a origem da Importacao				 �
//����������������������������������������������������������������
Private aRotina   := MenuDef(cAlias)

//��������������������������������������������������������������Ŀ
//� Define colunas com os campos a serem utilizados na MarkBrowse�
//����������������������������������������������������������������
Aadd(aCpoBrw,{"QEP_OK"    ,," "})
Aadd(aCpoBrw,{"QEP_FORNEC",,STR0012}) //"Forn/Cliente"
Aadd(aCpoBrw,{"QEP_LOJFOR",,STR0013}) //"Loja"
Aadd(aCpoBrw,{"QEP_PRODUT",,STR0014}) //"Produto"
Aadd(aCpoBrw,{"QEP_DTENTR",,STR0015}) //"Entrada"
Aadd(aCpoBrw,{"QEP_HRENTR",,STR0016}) //"Hora"
Aadd(aCpoBrw,{"QEP_LOTE"  ,,STR0017}) //"Lote"
Aadd(aCpoBrw,{"QEP_DOCENT",,STR0018}) //"Documento"
Aadd(aCpoBrw,{"QEP_TAMLOT",,STR0019}) //"Tamanho"
Aadd(aCpoBrw,{"QEP_TAMAMO",,STR0020}) //"Amostra"
Aadd(aCpoBrw,{"QEP_PEDIDO",,STR0021}) //"Pedido"
Aadd(aCpoBrw,{"QEP_NTFISC",,STR0022}) //"Nota Fiscal"
Aadd(aCpoBrw,{"QEP_SERINF",,STR0023}) //"Serie NF"
Aadd(aCpoBrw,{"QEP_DTNFIS",,STR0024}) //"Data NF"
Aadd(aCpoBrw,{"QEP_TES"   ,,STR0056}) //TES
Aadd(aCpoBrw,{"QEP_TIPDOC",,STR0025}) //"Tipo DOC"
Aadd(aCpoBrw,{"QEP_CERFOR",,STR0026}) //"Certificado"
Aadd(aCpoBrw,{"QEP_DIASAT",,STR0027}) //"Dias atraso"
Aadd(aCpoBrw,{"QEP_SOLIC" ,,STR0028}) //"Solicitante"
Aadd(aCpoBrw,{"QEP_PRECO" ,,STR0029}) //"Preco"
Aadd(aCpoBrw,{"QEP_EXCLUI",,STR0030}) //"Exclusao"             
Aadd(aCpoBrw,{"QEP_CODTAB",,STR0066}) //"Status da Importacao"
Aadd(aCpoBrw,{"QEP_LOTORI",,STR0057}) //"Tam Lote original"
//Adiciona no Browse campos de usuarios.
If Len(aCpoUsu) > 0  
	For nY:=1 to Len(aCpoUsu)
		cCampo := GetSx3Cache("QEP_"+aCpoUsu[nY],"X3_CAMPO")
		If !Empty(cCampo)
			Aadd(aCpoBrw,{Alltrim(cCampo),,AllTrim(QAGetX3Tit("QEP_"+aCpoUsu[nY]))})
	    EndIf 
	Next nY	    
EndIF

//��������������������������������������������������������������Ŀ
//� Endereca a funcao											 �
//����������������������������������������������������������������
dbSelectArea(cAlias)			
If cAlias == "TMP"
  	cFilInc := 'QEP_CODTAB <> "1"'
	MsgRun(STR0084,STR0085,{||dbSetFilter({||&cFilInc},cFilInc)}) //"Selecionando as Entradas..." ### "Aguarde..."
    dbGoTop()
	MarkBrow(cAlias,"QEP_OK","QEP_CODTAB=='2'",aCpoBrw,@lInverte,@cMarca,"Q183MkAllI()",,,,"Q183MarkAny()")
Else                                                                      
	cFilInc := 'QEP_FILIAL == xFilial("QEP")'+'.And.'+'QEP_CODTAB <> "1"'
	MsgRun(STR0084,STR0085,{||dbSetFilter({||&cFilInc},cFilInc)}) //"Selecionando as Entradas..." ### "Aguarde..."
    dbGoTop()
	MarkBrow(cAlias,"QEP_OK","QEP_CODTAB#'2'",aCpoBrw,@lInverte,@cMarca,"Q183MkAllQ()",,,,"Q183MarkAny()")	
EndIf	
dbSelectArea(cAlias) //Desliga o Filtro Ativo
Set Filter to
oBrw := GetObjBrow()
freeObj(oBrw)
 
Return(NIL)    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183MkAllI � Autor �Paulo Emidio de Barros� Data �30/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca todos os registros provenientes da Importacao TXT	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183MkAllI()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183MkAllI()
Local aAreaAnt := GetArea()

dbSelectArea("TMP") 
dbGoTop()
dbEval({||Q183MarkAny("TMP")})

RestArea(aAreaAnt)

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183MkAllQ � Autor �Paulo Emidio de Barros� Data �30/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Marca todos os registros provenientes da ReImportacao no QEP���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183MkAllQ()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183MkAllQ()
Local aAreaAnt := GetArea()

dbSelectArea("QEP") 
dbGoTop()
While !Eof()
    Q183MarkAny("QEP")
   dbSkip()
Enddo      

RestArea(aAreaAnt)
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183MarkAny� Autor �Paulo Emidio de Barros� Data �30/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � realiza a marca do registro corrente na MarkBrowse		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183MarkAny(expc1,expl1)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Alias corrente na MarkBrowse						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183MarkAny(cAlias)
Default cAlias := Alias()

RecLock(cAlias,.F.)      
If IsMark("QEP_OK",ThisMark(),ThisInv())
	Replace QEP_OK With " "
Else
	Replace QEP_OK With cMarca
EndIf
MsUnLock()

Return(NIL)
                       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183GrvImp � Autor �Paulo Emidio de Barros� Data �30/05/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao das Entradas provenientes do QEP (Entra-���
���			 � das Inconsistentes), atraves da chamada da Q183GravaTmp()  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183GrvImp()											 	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183GrvImp(lDispLog) 
Default lDispLog := .T.
                               
//��������������������������������������������������������������Ŀ
//� Realiza a gravacao da Entrada								 �
//����������������������������������������������������������������
Processa({||Q183GravaTmp(If(mv_par01==1,"QEP","TMP"),lDispLog)},OemToAnsi(STR0050),;//"Gravando os dados referente a Entrada"
	OemToAnsi(STR0051),.F.) //"Gravando Registro..."

Return(.T.)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183GravaTmp� Autor �Paulo Emidio de Barros� Data �29/05/2001���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a gravacao das Entradas e Inconsistencias 		   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183GravaTmp(EXPC1,EXPL1)							       ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do Arquivo Temporario                         ���
���			 � ExpL1 = Exibe o Log de Importacao						   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function Q183GravaTmp(cAlias,lDispLog) 
Local aDadosImp     
Local aRetQie 
Local lQuery   := .F.
Local cQuery    := ''
Local cIndexQEP := ''
Local cChave    := ''
Local nIndexQEP := ''
Local nCpoUsu   := 0 
Local lQE183GRV := ExistBlock("QE183GRV")
Local aStruQEP  
Local nPosCpo   := 0
Local nTmLote   := TamSX3("D1_LOTECTL")[1]
Local nTmSubLote := TamSX3("D1_NUMLOTE")[1]

//�����������������������������������������������������������������������������������Ŀ
//�              Array de Integracao dos dados - (LayOut para Importacao)             � 
//�����������������������������������������������������������������������������������Ĵ
//�                 Descricao               �   Origem Materiais   � TIPO � TAM � DEC � 
//�����������������������������������������������������������������������������������Ĵ
//�                							�                      �	  �		�     � 
//� [01] - Numero da Nota Fiscal 	 		� D1_DOC               �  C   �	06	�  0  �  
//� [02] - Serie da Nota Fiscal           	� D1_SERIE   	       �  C	  �	03	�  0  � 
//� [03] - Tipo da Nota Fiscal   		 	� D1_TIPO              �  C   �	01	�  0  �  
//� [04] - Data de Emissao da Nota Fiscal   � D1_EMISSAO           �  D	  �	08	�  0  �
//� [05] - Data de Entrada da Nota Fiscal   � D1_DTDIGIT           �  D	  �	08	�  0  �
//� [06] - Tipo de Documento -> default "NF"� "NF" ou "REMITO"     �  C	  �	06	�  0  � 
//� [07] - Item da Nota Fiscal				� D1_ITEM              �  C	  �	02	�  0  � 
//� [08] - Numero do Remito (Localizacoes)  � D1_REMITO            �  C	  �	12	�  0  � 
//� [09] - Numero do Pedido de Compra       � D1_PEDIDO            �  C	  �	06	�  0  �
//� [10] - Item do Pedido de Compra         � D1_ITEMPC            �  C	  �	02	�  0  �
//� [11] - Codigo Fornecedor/Cliente        � D1_FORNECE           �  C	  �	06	�  0  �
//� [12] - Loja Fornecedor/Cliente          � D1_LOJA     	       �  C	  �	02	�  0  �
//� [13] - Numero do Lote do Fornecedor     � D1_LOTEFOR     	   �  C	  �	18	�  0  �
//� [14] - Codigo do Solicitante            � SPACE(6)     		   �  C   �	06	�  0  �
//� [15] - Codigo do Produto                � D1_COD     	       �  C	  �	06	�  0  �
//� [16] - Local Origem    				    � D1_LOCAL   	   	   �  C	  �	02	�  0  �
//� [17] - Numero do Lote             		� D5_LOTECTL 	       �  C	  �	10	�  0  �
//� [18] - Sequencia do Sub-Lote         	� D5_NUMLOTE     	   �  C	  �	06	�  0  �
//� [19] - Numero Sequencial                � D1_NUMSEQ            �  C	  �	06	�  0  � 
//� [20] - Numero do CQ					    � D1_NUMCQ		       �  C	  �	06	�  0  �
//� [21] - Quantidade             			� D1_QUANT		       �  N	  � 11	�  2  �
//� [22] - Preco             				� D1_TOTAL 		       �  N	  �	14	�  2  �
//� [23] - Dias em atraso				    � D1_DTDIGIT-C7_DATPRF �  N	  �	04	�  0  �
//� [24] - TES (somente Materiais)			� D1_TES		       �  C	  �	03	�  0  �
//� [25] - Origem							� FunName()		       �  C	  �	08	�  0  �
//� [26] - Origem Importacao TXT			� 				       �  C	  �	12	�  0  �
//� [27] - Quantidade do lote original		� 					   �  N	  � 11	�  2  �
//� [28] - Hora da Entrada					� 					   �  C	  � 05	�  0  �
//�                					  	    �	      		       �	  �		�     �
//�������������������������������������������������������������������������������������

dbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Filtras as Inconsistencias, quando for Importacao Normal sem �
//� a exibicao do LOG de Registros.								 �
//����������������������������������������������������������������
Pergunte("QEA183",.F.)
If mv_par01 == 1 .And. mv_par04 == 2      
 	lQuery := .T.
 	 //Filtra as Entradas no Periodo
	 cAlias   := "QRYQEP"           
	 aStruQEP := QEP->(dbStruct())
	 cQuery   := "   SELECT * "
	 cQuery   += "     FROM "+RetSqlName("QEP")+" QEP "
	 cQuery   += "    WHERE QEP.QEP_FILIAL = '"+xFilial("QEP")+"' AND "
	 cQuery   += "          QEP.QEP_CODTAB = '2' AND "                      
	 cQuery   += "          QEP.D_E_L_E_T_ <> '*' "
	 cQuery   += " ORDER BY "+SqlOrder(QEP->(IndexKey()))
	 cQuery   := ChangeQuery(cQuery)
	
	 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	 For nPosCpo := 1 To Len(aStruQEP)
		 If aStruQEP[nPosCpo,2]<>"C"
			 TcSetField(cAlias,aStruQEP[nPosCpo,1],aStruQEP[nPosCpo,2],aStruQEP[nPosCpo,3],aStruQEP[nPosCpo,4])
		 EndIf
	 Next nPosCpo
EndIf

dbGoTop()
ProcRegua(LastRec())
While !Eof()	

	IncProc()
   
	//��������������������������������������������������������������Ŀ
	//� Importa somente os Itens selecionados na MarKBrowse			 �
	//����������������������������������������������������������������
	If lDispLog	        
		If !IsMark("QEP_OK",cMarca) .Or. !(QEP->QEP_FILIAL == xFilial("QEP")) .Or. QEP_CODTAB == "1"	.Or. (QEP_CODTAB == "2" .And. cAlias == "TMP")
			dbSkip()
			Loop
		EndIf
	EndIf
 	
	//��������������������������������������������������������������Ŀ
	//� Grava os dados referentes ao Inspecao de Entradas (SIGAQIE)  �
	//����������������������������������������������������������������
	aDadosImp := {QEP_NTFISC,;                               			//01-Numero da Nota Fiscal 	 		
		QEP_SERINF,;                                           			//02-Serie da Nota Fiscal           	
		If(cAlias == "TMP","N",QEP_TIPONF),;                            //03-Tipo da Nota Fiscal   		 	
		If(cAlias == "TMP",StoD(QEP_DTNFIS),QEP_DTNFIS),;               //04-Data de Emissao da Nota Fiscal   
		If(cAlias == "TMP",StoD(QEP_DTENTR),QEP_DTENTR),;               //05-Data de Entrada da Nota Fiscal   
		QEP_TIPDOC,; 								                    //06-Tipo de Documento
		If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_ITEMNF"})>0,QEP_ITEMNF,Space(TamSx3("D1_ITEM")[1])),QEP_ITEMNF),;  //07-Item da Nota Fiscal			
		Space(TamSx3("D1_REMITO")[1]),;                                 //08-Numero do Remito (Localizacoes)  
		QEP_PEDIDO,;                                                    //09-Numero do Pedido de Compra       
		If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_ITEMPC"})>0,QEP_ITEMPC,Space(TamSx3("D1_ITEMPC")[1])),QEP_ITEMPC),; //10-Item do Pedido de Compra         
		QEP_FORNEC,;                                                    //11-Codigo Fornecedor/Cliente        
		QEP_LOJFOR,;                                                    //12-Loja Fornecedor/Cliente          
		QEP_DOCENT,;                                           			//13-Numero do Lote do Fornecedor (Doc de Entrada)     
		QEP_SOLIC,;                                                     //14-Codigo do Solicitante            
		QEP_PRODUT,;                                                    //15-Codigo do Produto                
		If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_LOCORI"})>0,QEP_LOCORI,Space(TamSx3("D1_LOCAL")[1])),QEP_LOCORI),;  //16-Local Origem    				  
		SubStr(QEP_LOTE,1,nTmLote),;                                    //17-Numero do Lote             	
		SubStr(QEP_LOTE,nTmLote+1,nTmSubLote),;                         //18-Sequencia do Sub-Lote         
		If(cAlias == "TMP",IIF(Ascan(aStruTXT,{|x|x[3]=="QEP_NUMSEQ"})>0,QEP_NUMSEQ,Space(TamSx3("D1_NUMSEQ")[1])),QEP_NUMSEQ),; //19-Numero Sequencial             
		QEP_CERFOR,;                                                    //20-Numero do CQ					
		Val(QEP_TAMLOT),;                                               //21-Quantidade             		
		If(cAlias == "TMP",Val(QEP_PRECO),QEP_PRECO),;                  //22-Preco             			
		If(cAlias == "TMP",Val(QEP_DIASAT),QEP_DIASAT),;                //23-Dias de atraso		
		QEP_TES,;                                                       //24-TES 
		If(cAlias == "TMP",AllTrim(FunName()),QEP_ORIGEM),;             //25-Origem						
		If(cAlias == "TMP",mv_par03,QEP_IMPORT),;                       //26-Origem da Importacao TXT
		QEP_LOTORI,;                                                    //27-Tamanho do lote original
		QEP_HRENTR}                                                     //28-Hora da Entrada
	
	//��������������������������������������������������������������Ŀ
	//� Realiza a integracao Materiais x Inspecao de Entradas		 �
	//����������������������������������������������������������������
	aRetQie := qAtuMatQie(aDadosImp,If(QEP_EXCLUI=="S",2,1),If(cAlias=="TMP",.T.,.F.))
   
	//������������������������������������������������������������������Ŀ
	//� Realiza gravacao dos campos incluidos pelo usuario no Import.imp �
	//��������������������������������������������������������������������
	If Len(aCpoUsu) > 0                 
	
		If aRetQie[1] == "C" .Or. aRetQie[1] == " " //Entrada Certificada e/ou a Inspecionar 
			For nCpoUsu := 1 to Len(aCpoUsu)        
				SX3->(dbSetOrder(2))
				If SX3->(dbSeek("QEK_"+aCpoUsu[nCpoUsu]))
					If SX3->(dbSeek("QEP_"+aCpoUsu[nCpoUsu]))
					    RecLock("QEK",.F.)
					    QEK->(&("QEK_"+aCpoUsu[nCpoUsu])) := TMP->(&("QEP_"+aCpoUsu[nCpoUsu]))
					    MsUnlock()
				    EndIf
				EndIf
			Next nCpoUsu
			
		ElseIf aRetQie[1] == "E" //Ocorrencia de Erro
			For nCpoUsu := 1 to Len(aCpoUsu)
				SX3->(dbSetOrder(2))
				If SX3->(dbSeek("QEP_"+aCpoUsu[nCpoUsu]))
					RecLock("QEP",.F.)
			    	QEP->(&("QEP_"+aCpoUsu[nCpoUsu])) := TMP->(&("QEP_"+aCpoUsu[nCpoUsu]))
			    	MsUnlock()
			    EndIf	
			Next	
			
		EndIf                             
	EndIf
						
	dbSelectArea(cAlias)     
	If cAlias == 'TMP' 
		RecLock('TMP',.F.)
		TMP->QEP_CODTAB := If(aRetQie[3],'1','2')	
		MsUnLock()
	EndIf
	
	//���������������������������������������������������������������Ŀ
	//�Ponto de Entrada apos grava��o das tabelas QEP e QEK.          �
	//�����������������������������������������������������������������
	If lQE183GRV
		ExecBlock("QE183GRV",.F.,.F.)
	EndIf
	
	dbSkip()
	
EndDo

//��������������������������������������������������������������Ŀ
//� Restaura a area original das Inconsistencias				 �
//����������������������������������������������������������������  
If mv_par01 == 1 .And. mv_par04 == 2 //Importacao Normal, Sem LOG
	dbSelectArea(cAlias)
	If lQuery 
	 	dbCloseArea() 
	Else                
		RetIndex("QEP")
		Set Filter To
		fErase(cIndexQEP+OrdBagExt())
	EndIf
	dbSelectArea("QEP")
EndIf

//Exclui o arquivo TXT, que foi importado
If mv_par01 == 2
	fErase(cFileTMP)
EndIf

Return(.T.)
       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183ExcImp � Autor �Paulo Emidio de Barros� Data �04/06/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a exclusao das Entradas inconsistentes			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183ExcImp()											 	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183ExcImp()
Local lRet := .T.

//��������������������������������������������������������������Ŀ
//� Realiza a gravacao da Entrada								 �
//����������������������������������������������������������������

	If !MsgNoYes (STR0088) //Deseja excluir esta entrada?
		lRet :=.F.
	Endif

	If lRet 
		Processa({||Q183DelInc("QEP")},OemToAnsi(STR0054),; //"Excluindo Entradas Inconsistentes"
			OemToAnsi(STR0055),.F.) //"Excluindo Registro..."
	EndIf
	
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183DelInc � Autor �Paulo Emidio de Barros� Data �04/06/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a exclusao das Entradas inconsistentes no QEP	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183DelInc()											 	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function q183DelInc(cAlias)
dbSelectArea(cAlias)
dbGoTop()
ProcRegua(LastRec())
While !Eof()	
	IncProc()

	//��������������������������������������������������������������Ŀ
	//� Exclue somente os registros marcados						 �
	//����������������������������������������������������������������
	If !IsMark("QEP_OK",cMarca)	
		dbSkip()
		Loop
	EndIf             
	
	RecLock(cAlias,.F.)
	dbDelete()
	MsUnLock()
	dbSkip()
EndDo

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIEA180    � Autor �Paulo Emidio de Barros� Data �01/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Compatibiliza a chamada nas versoes anteriores			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIEA180() 												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIEA180()
QIEA183()	
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIEA190    � Autor �Paulo Emidio de Barros� Data �01/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Compatibiliza a chamada nas versoes anteriores			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIEA190() 												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIEA190()
QIEA183()
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIEM060    � Autor �Paulo Emidio de Barros� Data �01/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Compatibiliza a chamada nas versoes anteriores			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIEM060() 												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QIEM060()
QIEA183()
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183Ocor   � Autor �Paulo Emidio de Barros� Data �04/06/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a chamada do Relatorio de ocorrencias			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183Ocor()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183Ocor()
Local wnrel    := "QIEA183"
Local cString  := "QEK"
Local aAreaAnt := GetArea()
Local cDesc1   := OemToAnsi(STR0068) //"Neste relat�rio ser�o relacionadas as entradas"
Local cDesc2   := OemToAnsi(STR0069) //"dos Produtos/Fornecedores."
Local cDesc3   := "" 
Local aSX1    

aSX1 := QA_SaveSX1() //Salva as perguntas

Private cTitulo   := OemToAnsi(STR0070) //"Relatorio de Ocorrencias da Importacao"
Private cTamanho  := "M"
Private cPerg     := "Q183OC"
Private aReturn   := {STR0071, 1,STR0072, 1, 2, 1, "",1 } //"Zebrado" ### "Administracao"
Private cNomeProg := "QIEA183"
Private nLastKey  := 0     

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("Q183OC",.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,,,,.F.)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| Q183Imp(@lEnd,wnrel,cString)},cTitulo)

RestArea(aAreaAnt)

QA_RestSX1(aSX1) //Recupera as Perguntas 

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183Imp    � Autor �Paulo Emidio de Barros� Data �04/06/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a Impressao do Relatorio de Ocorrencias			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183Imp()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Q183Imp(lEnd,wnrel,cString)								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183Imp(lEnd,wnrel,cString)
Local cbTxt   := Space(10)
Local cbCont  := 0
Local nTipo   := If(aReturn[4]==1,15,18)
Local cAprv	  := "A"+Space(TamSX3("QEP_ERRO")[1]-1)
Local cCabec1 := " "
Local cCabec2 := " "


If mv_par01 == 1 .or. mv_par01 == 2
	
	//��������������������������������������������������������������Ŀ
	//� Imprime as entradas inconsistentes 							 �
	//����������������������������������������������������������������
	
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	//Fornecedor       Loja Produto         Data Entrada Lote              Inconsistencia
	cCabec1 := STR0073 //"Fornecedor       Loja Produto         Data Entrada Lote              Inconsistencia"		
	cCabec2 := " "
	Li      := 80
	m_Pag   := 01
	
	dbSelectArea("QEP")
	dbSetOrder(1)
	MsSeek(xFilial("QEP")+"2")
	SetRegua(RecCount())
	While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "2"
		If lEnd
			@PROW()+1,001 PSAY STR0074 //"CANCELADO PELO OPERADOR"
			Exit
		Endif
	
		If QEP->QEP_IMPFIC == "S" .or. QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
		   QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)
			dbSkip()
			Loop
		EndIf
		IncRegua()
		
		//��������������������������������������������������������������Ŀ
		//� Impressao do Cabecalho										 �
		//����������������������������������������������������������������
		If Li > 58
			Cabec(STR0075,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas Inconsistentes"
			Li++
		Endif
	
		@ Li,000 PSAY QEP_FORNEC
		@ Li,017 PSAY QEP_LOJFOR
		@ Li,022 PSAY QEP_PRODUT
		@ Li,053 PSAY QEP_DTENTR
		@ Li,066 PSAY QEP_LOTE
		@ Li,084 PSAY QEP_ERRO
		Li++
		dbSkip()	
		
	EndDo
Endif 
if mv_par01 == 1 .or. mv_par01 == 3	
	//��������������������������������������������������������������Ŀ
	//� Imprime as entradas em Skip-Lote 							 �
	//����������������������������������������������������������������
	
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	//Fornecedor          Loja  Produto          Data Entrada  Lote                                       
	cCabec1 := STR0076 //"Fornecedor          Loja  Produto          Data Entrada  Lote"
	cCabec2 := " "
	Li      := 80
	m_Pag   := 01
	
	dbSelectArea("QEP")
	dbSetOrder(1)
	MsSeek(xFilial("QEP")+"1")
	While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1"
		If lEnd
			@PROW()+1,001 PSAY STR0077 //"CANCELADO PELO OPERADOR"
			Exit
		Endif
	
		If QEP->QEP_ERRO # cAprv .Or. QEP->QEP_EXCLUI == "S" .Or. QEP->QEP_IMPFIC == "S" .or. ;
		   QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
		   QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)		
			dbSkip()
			Loop
		EndIf
		
		IncRegua()
	
		//��������������������������������������������������������������Ŀ
		//� Impressao do Cabecalho										 �
		//����������������������������������������������������������������
		If Li > 58
			Cabec(STR0078,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas em Skip-Lote"
			Li++
		Endif
		
		@ Li,000 PSAY QEP_FORNEC
		@ Li,020 PSAY QEP_LOJFOR
		@ Li,026 PSAY QEP_PRODUT
		@ Li,043 PSAY QEP_DTENTR
		@ Li,057 PSAY QEP_LOTE 
		Li++
		
		dbSkip()	
		
	EndDo
Endif
If mv_par01 == 1 .or. mv_par01 == 4	
	//��������������������������������������������������������������Ŀ
	//� Imprime as entradas a Inspecionar 							 �
	//����������������������������������������������������������������
	
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	//Fornecedor          Loja  Produto          Data Entrada  Lote
	cCabec1 := STR0079 //"Fornecedor          Loja  Produto          Data Entrada  Lote"
	cCabec2 := " "
	Li      := 80
	m_Pag   := 01
	
	dbSelectArea("QEP")
	dbSetOrder(1)
	MsSeek(xFilial("QEP")+"1")
	
	While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1"
		If lEnd
			@PROW()+1,001 PSAY STR0016	//"CANCELADO PELO OPERADOR"
			Exit
		Endif
		
		If QEP->QEP_ERRO == cAprv .Or. QEP->QEP_EXCLUI == "S" .Or. QEP->QEP_IMPFIC == "S" .or. ;
		   QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
		   QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)		
			dbSkip()
			Loop
		EndIf
		
		IncRegua()
	
		//��������������������������������������������������������������Ŀ
		//� Impressao do Cabecalho										 �
		//����������������������������������������������������������������
		If Li > 58
			Cabec(STR0080,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas a Inspecionar"
			Li++
		Endif
	
		@ Li,000 PSAY QEP_FORNEC
		@ Li,020 PSAY QEP_LOJFOR
		@ Li,026 PSAY QEP_PRODUT
		@ Li,043 PSAY QEP_DTENTR
		@ Li,057 PSAY QEP_LOTE
		Li++
		
		dbSkip()	
		
	EndDo
Endif
If mv_par01 == 1 .or. mv_par01 == 5	
	
	//�����������������������������������������������Ŀ
	//� Imprime as entradas excluidas pela importacao �
	//�������������������������������������������������
	
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//          1         2         3         4         5         6         7         8         9        10
	//Fornecedor          Loja  Produto          Data Entrada  Lote
	cCabec1 := STR0081 //"Fornecedor          Loja  Produto          Data Entrada  Lote"
	cCabec2 := " "
	Li      := 80
	m_Pag   := 01
	
	dbSelectArea("QEP")
	dbSetOrder(1)
	MsSeek(xFilial("QEP")+"1")
	While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1"
		If lEnd
			@PROW()+1,001 PSAY STR0082 //"CANCELADO PELO OPERADOR"
			Exit
		Endif
		
		If QEP->QEP_EXCLUI # "S"  .Or. QEP->QEP_IMPFIC == "S" .or. ;
		   QEP->QEP_FORNEC < mv_par02 .or. QEP->QEP_FORNEC > mv_par03 .or. QEP->QEP_PRODUT < mv_par04 .or. ;
		   QEP->QEP_PRODUT > mv_par05 .or. dtos(QEP->QEP_DTENTR) < dtos(mv_par06) .or. dtos(QEP->QEP_DTENTR) > dtos(mv_par07)		
			dbSkip()
			Loop
		EndIf
		
		IncRegua()
		
		//��������������������������������������������������������������Ŀ
		//� Impressao do Cabecalho										 �
		//����������������������������������������������������������������
		If Li > 58
			Cabec(STR0083,cCabec1,cCabec2,cNomeProg,cTamanho,nTipo,,.F.) //"Entradas excluidas"
			Li++
		Endif
		
		@ Li,000 PSAY QEP_FORNEC
		@ Li,020 PSAY QEP_LOJFOR
		@ Li,026 PSAY QEP_PRODUT
		@ Li,043 PSAY QEP_DTENTR
		@ Li,057 PSAY QEP_LOTE
		Li++
		
		dbSkip()	
		
	EndDo
Endif	
If Li != 80
	Roda(CbCont,cbtxt)
EndIf

Set device to Screen
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH() 

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183Ficha  � Autor �Paulo Emidio de Barros� Data �04/06/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza a chamada para Impressao das Fichas de Produtos Ins���
��� 		 � pecionados.												  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183Ficha()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183Ficha()                         
Local aAreaAnt := GetArea()
Local aSX1

aSX1 := QA_SaveSX1() //Salva as perguntas

//������������������������������������������������������������������Ŀ
//� Ponto de entrada para personalizar a rotina de impressao da ficha�
//� de produto.                                                      �
//��������������������������������������������������������������������
If ExistBlock("QIE183EN")
	ExecBlock("QIE183EN",.F.,.F.,{"QIEA200"})
Else
	//������������������������������������������������������������������Ŀ
	//� Funcao que imprime as fichas dos produtos para todas as entradas �
	//� marcadas para inspecao.                                          �
	//��������������������������������������������������������������������
	QIER220("QIEA200")
EndIf

RestArea(aAreaAnt)

QA_RestSX1(aSX1)

Return(NIL)       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q183DelFic � Autor �Paulo Emidio de Barros� Data �13/08/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exclui as Entradas com Ficha Produto impressa, ou Certifi- ���
��� 		 � cadas.													  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q183DelFic()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183DelFic()    
Local aTam       := TamSX3("QEP_ERRO")
Local cCertifica := "A"+Space(aTam[1]-1)

//������������������������������������������������������������������Ŀ
//� Exclui a Entradas referentes a importacao anterior, se a Ficha do�
//� produto foi impressa, ou se a Entrada foi certificada.			 �
//��������������������������������������������������������������������
dbSelectArea("QEP")
dbSetOrder(1)
If dbSeek(xFilial("QEP")+"1")
	While !Eof() .And. (QEP_FILIAL+QEP_CODTAB) == (xFilial("QEP")+"1")
		If (QEP->QEP_IMPFIC == "S") .Or. (QEP->QEP_ERRO == cCertifica) .Or.;
			(QEP->QEP_EXCLUI == "S")
	          RecLock("QEP",.F.)
	          dbDelete()
	          MsUnLock()
	    EndIf
	    dbSkip()
	EndDo                 
Endif
	
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Q183Legend� Autor �Paulo Emidio de Barros � Data �20/08/2001���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Define as Legendas utilizadas nas Entradas				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Q183Legend()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NIL														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183Legend() 
Local aLegenda := {}
If mv_par01 == 1
	Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0058)}) //"Pendente para Importacao Normal"
	Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0059)}) //"Importacao realizada com Sucesso"
Else
	Aadd(aLegenda,{"BR_VERDE",   OemToAnsi(STR0060)}) //"Pendente para Importacao TXT"
	Aadd(aLegenda,{"BR_VERMELHO",OemToAnsi(STR0061)}) //"Importacao realizada com Inconsistencia"
EndIf	

BrwLegenda(cCadastro,STR0062,aLegenda) //"Importacao das Entradas"
Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �Q183OpenTx� Autor �Paulo Emidio de Barros � Data �23/04/2003���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna a Estrutura do layout de Importacao TXT			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Q183OpenTxt()											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � EXPA1 = Estrutura do Layout de Importacao TXT			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEA183													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Q183OpenTxt()
Local aCpoTxt  := {}
Local nHandle  := 0
Local nTamArq  := 0
Local nTamLin  := 0
Local nBytes   := 0
Local xBuffer 
Local aStruTxt := {}
Local nPosIni  := 0
Local nPosFin  := 0
Local cCpoOri  := " "
Local cCpoPad  

cCpoPad  := "QEP_FORNEC,QEP_LOJFOR,QEP_PRODUT,QEP_DTENTR,QEP_HRENTR,QEP_LOTE,QEP_DOCENT,QEP_TAMLOT,QEP_TAMAMO"
cCpoPad  += ",QEP_PEDIDO,QEP_NTFISC,QEP_SERINF,QEP_DTNFIS,QEP_TIPDOC,QEP_CERFOR,QEP_DIASAT,QEP_SOLIC,QEP_PRECO,QEP_EXCLUI"

//Verifica o caminho para gravacao do layout padrao,caso o mesmo nao exista
If !File("IMPORT.IMP")

	//layout padrao para o arquivo de Importacao
	Aadd(aCpoTxt,"00010006QEP_FORNEC")
	Aadd(aCpoTxt,"00070008QEP_LOJFOR")
	Aadd(aCpoTxt,"00090023QEP_PRODUT")
	Aadd(aCpoTxt,"00240031QEP_DTENTR")
	Aadd(aCpoTxt,"00320036QEP_HRENTR")
	Aadd(aCpoTxt,"00370052QEP_LOTE  ")
	Aadd(aCpoTxt,"00530068QEP_DOCENT")
	Aadd(aCpoTxt,"00690076QEP_TAMLOT")
	Aadd(aCpoTxt,"00770084QEP_TAMAMO") 
	Aadd(aCpoTxt,"00850094QEP_PEDIDO")
	Aadd(aCpoTxt,"00950100QEP_NTFISC")
	Aadd(aCpoTxt,"01010103QEP_SERINF")
	Aadd(aCpoTxt,"01040107QEP_ITEMNF")
	Aadd(aCpoTxt,"01080115QEP_DTNFIS")
	Aadd(aCpoTxt,"01160121QEP_TIPDOC")
	Aadd(aCpoTxt,"01220133QEP_CERFOR")  
	Aadd(aCpoTxt,"01340137QEP_DIASAT")
	Aadd(aCpoTxt,"01380147QEP_SOLIC ")
	Aadd(aCpoTxt,"01480159QEP_PRECO ")
	Aadd(aCpoTxt,"01600160QEP_EXCLUI")  

	nHandle := fCreate("IMPORT.IMP")
	Aeval(aCpoTxt,{|x|cString:=x+Chr(13)+Chr(10),fWrite(nHandle,cString)})
Else
	nHandle := fOpen("IMPORT.IMP",2+64)
EndIf	

//Posiciona no arquivo
nTamArq := fSeek(nHandle,0,2)
nTamLin := 20
fSeek(nHandle,0,0)

While nBytes < nTamArq
	xBuffer := Space(nTamLin)
	fRead(nHandle,@xBuffer,nTamLin)

	nPosIni := Val(SubStr(xBuffer,1,4))      //Posicao Inicial
	nPosFin := Val(SubStr(xBuffer,5,4))      //Posicao Final
	cCpoOri := AllTrim(SubStr(xBuffer,9,10)) //Campo a receber o Valor   
    
    If cCpoOri $ "QEP_NTFISC" .AND. nPosFin-nPosIni+1 <> TamSx3("QEP_NTFISC")[1]
         MsgAlert(STR0087)  //"A configura��o da estrutura do arquivo de importa��o esta inconsistente! Verifique 'Inicio', 'Fim' e 'Tamanho' do campo Nota Fiscal atrav�s da rotina Miscelanea->Duplicacao->Adm.Txt."
    EndIf
    
	Aadd(aStruTxt,{nPosIni,nPosFin,cCpoOri})  
    //Verifica campos incluidos pelo usuario.
	If !(Alltrim(cCpoOri)$cCpoPad)
		Aadd(aCpoUsu,Substr(Alltrim(cCpoOri),5,10))
	EndIf
	nBytes+=nTamLin
EndDo

//Fecha o arquivo de configuracao
fClose(nHandle)

Return(aStruTxt)          

