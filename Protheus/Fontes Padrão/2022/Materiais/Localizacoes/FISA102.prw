#INCLUDE "FISA102.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "fwlibversion.ch"

//#DEFINE _SEPARADOR ";"
#DEFINE _POSCGC		1
#DEFINE _POSDENOM 	2
#DEFINE _POSIMPGAN 	3
#DEFINE _POSIMPIVA 	4
#DEFINE _POSMONOT 	5
#DEFINE _POSINTSOC 	6
#DEFINE _POSEMPLEA 	7
#DEFINE _POSACTMON 	8
#DEFINE _aPOSICIO		{}
#DEFINE STR0027 "Primero se debe importar un padron"
#DEFINE _BUFFER 16384
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � FISA125  � Autor � Raul Ortiz		    � Data � 04/06/2015���
��������������������������������������������������������������������������Ĵ��
���Descricao � Processa a partir de um arquivo TXT gerado pela AFIP        ���
���          � atualizando as aliquotas de percepcao/retencao na tabela    ���
���          � SFH (ingressos brutos).                                     ���
���������������������������������������������������������������������������ٱ�
��� Uso      � Fiscal - Argentina  				                           ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���Luis Enriquez �13/01/17�SERINN001-774�-Se realiza merge para hacer cam- ���
���              �        �             � bio para agregar "TOPCONN",para  ���
���              �        �             � que no genere archivo en carpeta ���
���              �        �             � system y siempre genere tabla co-���
���              �        �             � mo se realiz� para CTREE.        ���
���Luis Enriquez �11/03/19�DMINA-5660   �-Se realiza correcci�n de actuali-���
���              �        �             � zaci�n del campo A1/A2_TIPO cuan-���
���              �        �             � do tipo IVA es NI y monotributo  ���
���              �        �             � es diferente de NI. (ARG)        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/   

Function FISA102()
Local   cCombo := ""
Local   aCombo := {}
Local   oFld   := Nil

Private cMes   := StrZero(Month(dDataBase),2)
Private cAno   := StrZero(Year(dDataBase),4)
Private lRet   := .T.
Private lPer   := .T.
Private oDlg   := Nil
Private cAliasPdr	:= "PADRSC"

Public aQry := {}

	aAdd( aCombo, STR0002 ) //"1- Fornecedor"
	aAdd( aCombo, STR0003 ) //"2- Cliente"
	aAdd( aCombo, STR0004 ) //"3- Ambos"

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Padr�n de Sujetos Categorizados"
	 
	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"
	
	@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL 
	
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0008 PIXEL SIZE 165,075 //"&Importa��o de Arquivo TXT"
	
	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 005,005 SAY STR0009 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadstro    "
	@ 015,005 SAY STR0010 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente  x Imposto segundo arquivo TXT  "
	//@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "
	@ 045,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
	@ 045,055 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 045,070 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ 045,075 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]
	
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 025,178 BUTTON STR0013 SIZE 036,016 PIXEL ACTION ImpArq() //"&Importar"
	@ 045,178 BUTTON STR0020 SIZE 036,016 PIXEL ACTION ActArc(cCombo) //"&Importar"
	@ 065,178 BUTTON STR0023 SIZE 036,016 PIXEL ACTION DelTab(.T.) 
	@ 085,178 BUTTON STR0014 SIZE 036,016 PIXEL ACTION oDlg:End() 

ACTIVATE MSDIALOG oDlg CENTER

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ImpArq   � Autor � Raul Ortiz          � Data � 04/06/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicializa la importacion del archivo.                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aPar01 - Variable con las opciones de combo                ���
���          � cPar01 - Variable con la opcion elegida del combo          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal -  Argentina                          			 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpArq()
Local  cLine  := ""
Local  cVersion := FwLibVersion()
Local  cBuild	:= TCGetBuild()
Local  lProces := .F.
Local  lRetOk  := .F. 
Local  cPesq := "\"  
Local  cfinal:= ""
Local  Naux:= 0
Local  nTamba:= 0
Local cStartPath := GetSrvProfString("StartPath","")
Private cFile  := ""

	// Seleciona o arquivo
	cStartPath := StrTran(cStartPath,"/","\")
	cStartPath +=If(Right(cStartPath,1)=="\","","\")
	cFile := FGetFile()
	cfinal:= cFile
	If !Empty(cFile) 	
		If ! cFile $ cStartPath
			If ":" $ cFile
				CpyT2S(cFile,cStartPath,.T.)
			Endif
		EndIf
	EndIF	  
	If Empty(cFile)
		Return Nil
	Else
		If cBuild  >= "20181212" .and. cVersion >= "20201009"
			
			If Select(cAliasPdr) <> 0
				(cAliasPdr)->(dbCloseArea()) 
			EndIf
	
			If ( !MsFile(cAliasPdr,,"TOPCONN") )
				lCrea := .T.
			Else
				lCrea := MSGYESNO( STR0021, STR0001 )
				If lCrea
					lCrea := DelTab()
				EndIf
			Endif
			If lCrea 
				lProces:= MSGYESNO(STR0029)			
				If lProces				
					PrcFisa102(lRetOk)
				EndIf
			EndIf	
		Else
			If CreaTabla()
				Processa( {|| LeeArc()} , STR0019,"Importando datos", .T. )
			EndIf
		EndIf 		
	EndIf
	
	If !Substr(cFile,1,6) $ cStartPath
		While AT( cPesq, cfinal) > 0  		
 			Naux:=AT( cPesq, cfinal ) 
			Naux:=Naux+1
			nTamba:= Len(cfinal)
			cfinal:= SubStr(cfinal,Naux,nTamba)		
		EndDo
	EndIF
	FERASE(cStartPath+cfinal)
Return Nil

Static Function ActArc(cCombo)
Local	cTipo	:= ""

	cTipo   := Subs(cCombo,1,1)  

	If ( !MsFile(cAliasPdr,,"TOPCONN") )
		MsgAlert(STR0027)
	Else
		If  cTipo == "1" .Or. cTipo == "3"      //Procesa Proveedores
			Processa( {|| ProcRegs(.F.)}, STR0019,STR0018, .T. )	//Proveedores Percepciones (solo si el CUIT de SM0 existe en el padron)
		EndIf
		If  cTipo == "2" .Or. cTipo == "3"      //Procesa Clientes
			Processa( {|| ProcRegs(.T.)} , STR0019,STR0017, .T. )	//Proveedores Percepciones						
		EndIf
		MsgAlert(STR0026)
	EndIf
	
Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FGetFile � Autor � Ivan Haponczuk      � Data � 09.06.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Tela de sele��o do arquivo txt a ser importado.            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cRet - Diretori e arquivo selecionado.                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Buenos Aires Argentina - MSSQL                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FGetFile()

	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0015,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0015,,.T.)//"Selecionar arquivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FGetDir  � Autor � Ivan Haponczuk      � Data � 09.06.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Tela para procurar e selecionar o arquivo nos diretorios   ���
���          � locais/servidor/unidades mapeadas.                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oPar1 - Objeto TGet que ira receber o local e o arquivo    ���
���          �         selecionado.                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Buenos Aires Argentina - MSSQL                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	
	cDir := cGetFile(,STR0015,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ProcRegs � Autor � Raul Ortiz          � Data � 04/06/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Selecciona los registros de SA1 o SA2						    ���
���          � 										                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lCli = .T. si selecciono cliente                           ���
���          �        .F. si es Proveedor                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Argentina			                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ProcRegs(lCli)

Local aArea		:= getArea()
Local cQuery	:= ""	
Local cSA		:= Iif(lCli,InitSqlName("SA1"),InitSqlName("SA2"))	 
Local cMsg		:= Iif(lCli,STR0017,STR0018)       
Local cPref		:= Iif(lCli,"A1","A2")
Local cTmp 	    := Criatrab(nil,.F.)                               
Local nI		:= 0
Local cClave	:= ""
Local nCont     := 0
Local aDatos := {} 
Local cIndex := ""
	
// Seleccionar clientes que no esten bloqueados y cuyo CUIT no este vacio y sean registros que no 
// esten eliminados y para todas las filiales
		
	cQuery := " SELECT " + cPref + "_COD ," 
	cQuery +=		cPref + "_LOJA,"
	cQuery +=		cPref + "_CGC,  "
	cQuery +=		cPref + "_NOME, "
	cQuery +=		cPref + "_FILIAL "
	cQuery += " FROM "
	cQuery +=		cSA + " S"+ cPref + " " 
	cQuery += 	"WHERE "
	cQuery += 		cPref + "_CGC <> ' ' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + cPref + "_CGC "
																		   
	cQuery := ChangeQuery(cQuery)                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
					
	Count to nCont
	(cTmp)->(dbGoTop())
			
	ProcRegua(nCont) 


	While (cTmp)->(!eof())      //Clientes/Proveedores
		nI++
		IncProc(cMsg + str(nI))
		
		cClave := (cTmp)->&(cPref+"_CGC")
			
		If Select(cAliasPdr) == 0
			DbUseArea(.T.,"TOPCONN",cAliasPdr,cAliasPdr,.T.)
			
			cIndex := cAliasPdr+"1"
			If ( !MsFile(cAliasPdr,cIndex, "TOPCONN") )
				// Crear indice x cuit
				DbCreateInd(cIndex,"CUIT",{|| "CUIT" })
			EndIf
			Set Index to (cIndex)
		EndIf
		
		
		dbSelectArea(cAliasPdr)
		
		If (cAliasPdr)->(dbSeek((cClave)))
			UpdTablas((cTmp)->&(cPref+"_FILIAL") + (cTmp)->&(cPref+"_COD") + (cTmp)->&(cPref+"_LOJA"), cTmp, "S"+cPref,(cAliasPdr)->IMPGAN, (cAliasPdr)->IMPIVA,(cAliasPdr)->MONOT, .T. )
		Else
			UpdTablas((cTmp)->&(cPref+"_FILIAL") + (cTmp)->&(cPref+"_COD") + (cTmp)->&(cPref+"_LOJA"), "", "S"+cPref, "", "","", .F. )
		EndIf
		
		(cTmp)->(dbSkip())	    
	EndDo
	
	(cAliasPdr)->(dbCloseArea()) 
	(cTmp)->(dbCloseArea()) 
      
	RestArea(aArea)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � UpdTablas� Autor � Raul Ortiz          � Data � 05/06/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Actualiza los registros de SA1, SA2 y SFH				    ���
���          � 										                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cSeek = Clave para buscar en SA1 o SA2                     ���
���          � cAlias = Alias de la tabla que est� siendo procesada       ���
���          � cTabla = Origen de los datos SA1 o SA2						���
���          � cTipGan = Tipo de ganancia en el padron para el cuit en    ���
���          � proceso                                                    ���
���          � cTipIva = Tipo de Iva en el padron para el cuit en proceso ���
���          � lFnd = Indica si el cuit fue encontrado en el padron       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Argentina			                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function UpdTablas(cSeek, cAlias ,cTabla, cTipGan, cTipIva,cMonot , lFnd)
Local cPref		:= Substr(cTabla,2,2)
Local cClave 		:= cPref + "_FILIAL+" + cPref + "_COD+" + cPref + "_LOJA"
Local cInsGan  	:= ""
Local cTipo 		:= ""
Local cSA		:= InitSqlName(cTabla)
Local cSFH		:= InitSqlName("SFH")
Local cTmp 	    := "" 
Local cQuery	    := ""
Local nCont     	:= 0
Local lInser		:= .F.
Local cPercIVA	:= ""
	
	If lFnd
		If cTabla == "SA2"
			If AllTrim(cTipGan) $ "AC|S|EX"
				cInsGan := "S"
			ElseIf AllTrim(cTipGan) $ "NI|NC"
				cInsGan := "N"
			EndIf
		Else
			If AllTrim(cTipGan) $ "AC|S|EX"
				cInsGan := "1"
			ElseIf AllTrim(cTipGan) $ "NI|NC"
				cInsGan := "2"
			EndIf
		Endif
		
		If AllTrim(cTipIva) $ "AC|S"
			cTipo := "I"
			cPercIVA:= "S"
			
			cTemp := Criatrab(nil,.F.) 
			
			cQuery := "SELECT * "
			cQuery += "FROM "
			cQuery +=		cSFH + " SFH " 
			cQuery += 	"WHERE " 
			cQuery += 	"FH_FILIAL ='" + (cAlias)->&(cPref+"_FILIAL") + "' AND " 	
			If  cTabla == "SA1"	
				cQuery +=  	"FH_CLIENTE='" + (cAlias)->A1_COD	  	+ "' AND "
				cQuery += 	"FH_LOJA   ='" + (cAlias)->A1_LOJA   	+ "' AND "
			Else      
				cQuery +=  	"FH_FORNECE='" + (cAlias)->A2_COD		+ "' AND "
				cQuery += 	"FH_LOJA   ='" + (cAlias)->A2_LOJA   	+ "' AND "
			EndIF
			cQuery +=	"FH_IMPOSTO = 'IVP' AND "
					
			cQuery +=	"D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY  FH_FIMVIGE, FH_INIVIGE DESC"

			cQuery := ChangeQuery(cQuery)                    
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.) 
				 
			Count to nCont
			(cTemp)->(dbGoTop())
			
			If  nCont > 0 
				If (AllTrim((cTemp)->FH_FIMVIGE) == "" .and. CTOD("01/" + cMes + "/" + cAno) > STOD((cTemp)->FH_INIVIGE )) .or. (CTOD("01/" + cMes + "/" + cAno) > STOD((cTemp)->FH_FIMVIGE ) .and. AllTrim((cTemp)->FH_FIMVIGE) <> "") 
					lInser :=  .T.
				EndIf
			ElseIf nCont == 0 
				lInser :=  .T.
			EndIf
			
			If lInser
				Reclock("SFH",.T.)
					SFH->FH_FILIAL		:= (cAlias)->&(cPref+"_FILIAL")
					SFH->FH_AGENTE 		:= "S"
					If  cTabla == "SA1"	
						SFH->FH_CLIENTE		:= (cAlias)->&(cPref+"_COD")
					Else
						SFH->FH_FORNECE		:= (cAlias)->&(cPref+"_COD")
					EndIf
					SFH->FH_LOJA	    	:= (cAlias)->&(cPref+"_LOJA")
					SFH->FH_NOME	    	:= (cAlias)->&(cPref+"_NOME")
					SFH->FH_TIPO			:= "I"
					SFH->FH_PERCIBI		:= "N"
					SFH->FH_ZONFIS		:= "**"
					SFH->FH_IMPOSTO		:= "IVP"
					SFH->FH_ALIQ			:= 0
					SFH->FH_INIVIGE		:= CTOD("01/"+cMes+"/"+cAno)
					SFH->FH_FIMVIGE		:= CTOD("//")
					SFH->FH_ISENTO		:= "N"
					SFH->FH_APERIB		:= "S"
				SFH->(MsUnlock())
			EndIf
			
			(cTemp)->(dbCloseArea())
		ElseIf AllTrim(cTipIva) $ "AN|EX|NA|XN"
			cTipo := "X"
			cPercIVA :="N"
		ElseIf AllTrim(cTipIva) $ "NI|N"
			cTipo := "S"
			cPercIVA :="N"
		EndIf
	Else 
		cTipo := "S"
		cPercIVA :="N"
		If cTabla == "SA2"
			cInsGan := "N"
		Else
			cInsGan := "2"
		Endif
	EndIf

	If lFnd .And. cMonot <> "NI"
		cTipo := "M"
	ElseIf !lFnd
		cTipo := "S"
	Endif
		
	dbSelectArea(cTabla)
	(cTabla)->(dbSetOrder(RETORDEM(cTabla,cClave)))
	(cTabla)->(dbGoTop())
	If (cTabla)->(dbSeek((cSeek)))
		RecLock(cTabla, .F.)
		If !lFnd //No encontro en TXT
		    If !((cTabla)->&(cPref+"_TIPO") $ "E|F")
				(cTabla)->&(cPref+"_TIPO") := "S"
				(cTabla)->&(cPref+"_PERCIVA") := "N"
				If  cTabla == "SA2"
					(cTabla)->&(cPref+"_INSCGAN") := "N"
					(cTabla)->&(cPref+"_AGENRET") := "N"
				EndIf
			EndIf	
		Else
			If AllTrim(cTipo) <> ""
				(cTabla)->&(cPref+"_TIPO") := AllTrim(cTipo)
			EndIf
			If  cTabla == "SA2"
				If AllTrim(cInsGan) <> ""
					(cTabla)->&(cPref+"_INSCGAN") := AllTrim(cInsGan)
				EndIf
			EndIf
			(cTabla)->&(cPref+"_PERCIVA") := AllTrim(cPercIVA)
		EndIf
		(cTabla)->(MsUnLock())	
	EndIf
	
	(cTabla)->(dbCloseArea())
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � TXTSeek  � Autor � Ivan Haponczuk      � Data � 16.06.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Faz a busca do CGC informado no arquivo tambem informado   ���
���          � atraves do metodo de busca binaria, para a utilizacao      ���
���          � desse metodo de busca o arquivo deve estar ordenado por    ���
���          � CGC em ordem crescente.                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Local e nome do arquivo a ser feita a busca.      ���
���          � cPar02 - CGC a ser buscado no arquivo.                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRet - Vetor contendo as informacoes da linha encontrada   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Buenos Aires Argentina                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TXTSeek(cFile,cCGC, cRegimen)

	Local nPri    := 0
	Local nUlt    := 0
	Local nMeio   := 0
	Local nCGC    := 0
	Local lFnd    := .F.
	Local nReg1   := 0
	Local nReg2   := 0 
	Local aLinIni := 0
	Local aLinFin := 0
	Local aLin := {}
	
	
	
	nCGC := Val(cCGC)
	FT_FUSE(cFile)
	nPri := 1
	nUlt := FT_FLASTREC()

	//Excepcion: Que el CUIT no este en el archivo
	ft_FSkip(0)   
	aLinIni := SeperaStr(FT_FREADLN())  
	ft_FSkip(nUlt-1)
	aLinFin := SeperaStr(FT_FREADLN())   
	If   nCGC<Val(aLinIni[_POSCGC]) .Or. nCGC>Val(aLinFin[_POSCGC]) 
		 Return aLin
	Endif
	ft_FGoTop()                                

	Do While !lFnd
	    
		// Verifica se e o ultimo
		ft_FGoTop()
		ft_FSkip(nUlt-1)
		nReg1:= nUlt-1 
		aLin := SeperaStr(FT_FREADLN())
		If nCGC == Val(aLin[_POSCGC])
			lFnd := .T.
		EndIf
		
		// Verifica se e maior ou menor
		If !lFnd
			nMeio := Round(((nUlt-(nPri-1))/2),0)
			nMeio += (nPri-1)
			ft_FGoTop()
			ft_FSkip(nMeio-1)
			nReg2:= nMeio-1 			
			aLin := SeperaStr(FT_FREADLN())
			If nCGC == Val(aLin[_POSCGC])
				lFnd := .T.
			Else
				If nCGC <= Val(aLin[_POSCGC])
					nUlt := nMeio
				Else
					nPri := nMeio
				EndIf
			EndIf
		EndIf
		
		// Se nao existir no arquivo
		If !lFnd .And. (nMeio == 1   .Or. ( (nCGC > Val(aLin[_POSCGC]) .And. (nReg1-nReg2)==1 ) .Or. (nReg1-nReg2)==0))
			aLin := {}
			Exit
		EndIf
		/*If !lFnd .and. ( (nPri+1) == nUlt ) .and. ( nMeio == (Round(((nUlt-(nPri-1))/2),0)+(nPri-1)) )
			aLin := {}
			Exit
		EndIf*/
	EndDo
	FT_FUSE()

Return aLin

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SeperaStr� Autor � Raul Ortiz          � Data � 05/06/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Separa la linea ingresada por las posiciones indicadas     ���
���          � 										                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cLinea = Indica la linea a separar                         ���
���          �        						                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aDatos - Contiene los datos separados                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Argentina			                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function SeperaStr(cLinea)
Local aPoscio := {11,30,2,2,2,1,1,2}
Local nI := 0
Local nCont := 1
Local aDatos := {}

	For nI = 1 To Len(aPoscio)
		AADD(aDatos,Substr(cLinea, nCont, aPoscio[nI]))
		nCont += aPoscio[nI]
	Next

Return aDatos

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � LeeArc   � Autor � Raul Ortiz          � Data � 10/06/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Lee los registros del padron y los inserta a la base de    ���
���          � datos									                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�									                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Argentina			                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function LeeArc()
Local nHandle := 0 
Local aDatos := {}
Local nRecno	:= 0

	nHandle := FT_FUSE(cFile)
	
	if nHandle == -1
		return
	EndIf
	
	ft_FGoTop()
	ProcRegua(FT_FLASTREC()) 	
		 
	
	While !FT_FEOF()
		nRecno ++
		IncProc(STR0025 + str(nRecno))
		aDatos := SeperaStr(FT_FReadLn())

		If Len(aDatos) > 0
			
			dbSelectArea(cAliasPdr)
			RecLock(cAliasPdr,.T.)
				(cAliasPdr)->CUIT		:= aDatos[1]
				(cAliasPdr)->DENOM	:= aDatos[2]
				(cAliasPdr)->IMPGAN	:= aDatos[3]
				(cAliasPdr)->IMPIVA	:= aDatos[4]
				(cAliasPdr)->MONOT	:= aDatos[5]
				(cAliasPdr)->INTSOC	:= aDatos[6]
				(cAliasPdr)->EMPLEA	:= aDatos[7]
				(cAliasPdr)->ACTMON	:= aDatos[8]
			(cAliasPdr)->(MsUnLock())
		EndIf
		FT_FSKIP()
	
	End
	
	FT_FUSE()
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CreaTabla� Autor � Raul Ortiz          � Data � 10/06/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Crea la tabla para el padron dentro de la base de datos    ���
���          � 										                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�																	���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lCrea -  indica si se creo la Tabla                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Argentina			                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function CreaTabla()
Local cIndex	:= ""
Local aStru		:= {}
Local lCrea := .F.
	
	
	If Select(cAliasPdr) <> 0
		(cAliasPdr)->(dbCloseArea()) 
	EndIf
	
	If ( !MsFile(cAliasPdr,,"TOPCONN") )
			lCrea := .T.
		Else
			lCrea := MSGYESNO( STR0021, STR0001 )
			If lCrea
				lCrea := DelTab()
			EndIf
		Endif
		
		If lCrea
			AADD(aStru,{"CUIT"	,"C",011,0})
			AADD(aStru,{"DENOM"	,"C",030,0})
			AADD(aStru,{"IMPGAN"	,"C",002,0})
			AADD(aStru,{"IMPIVA"	,"C",002,0})
			AADD(aStru,{"MONOT"	,"C",002,0})
			AADD(aStru,{"INTSOC"	,"C",001,0})
			AADD(aStru,{"EMPLEA"	,"C",001,0})
			AADD(aStru,{"ACTMON"	,"C",002,0})
		MsCreate(cAliasPdr,aStru,"TOPCONN")
		EndIf
		
	DbUseArea(.T.,"TOPCONN",cAliasPdr,cAliasPdr,.T.)

		cIndex := cAliasPdr+"1"
	If ( !MsFile(cAliasPdr,cIndex, "TOPCONN") )
			// Crear indice x CUIT
			DbCreateInd(cIndex,"CUIT",{|| "CUIT" })
		EndIf
		Set Index to (cIndex)

Return lCrea

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � DelTab   � Autor � Raul Ortiz          � Data � 10/06/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Selecciona los registros de SA1 o SA2						    ���
���          � 										                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lDel = Indica si debe de enviar mensaje de error           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet = Indica si fue eliminada la Tabla                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Argentina			                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function DelTab(lDel)
Local cQuery 	:= ""
Local lRet 	:= .F.

Default lDel := .F.

   	cQuery := "DROP TABLE " + cAliasPdr           
	If TcSqlExec(cQuery) <> 0
		MsgAlert(STR0022)
	Else
		If lDel
			MsgAlert(STR0024)	
		EndIf
		lRet := .T.
	EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ProsArqu � Autor � Marivaldo Bezerra   � Data � 11/12/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Processa os registros do arquivo TXT 					   ���
���          � 										                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Argentina			                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ProsArqu()
 
Local oBulk as object
Local aStruct as array
Local nX as numeric
Local lCanUseBulk as logical
Local nUlt := 0
Local lProc := .F. 
Local cDatos := "" 

	nHandle := FT_FUSE(cFile)
	
	if nHandle == -1
		return
	EndIf
	nUlt:= FT_FLASTREC()	
 
    aStruct := {}
 
    aAdd( aStruct, { 'CUIT',  'C', 11,0 } )
    aAdd( aStruct, { 'DENOM', 'C', 30,0 } )
    aAdd( aStruct, { 'IMPGAN','C', 002, 0 } )
    aAdd( aStruct, { 'IMPIVA','C', 002, 0 } )
    aAdd( aStruct, { 'MONOT', 'C', 002, 0 } )
	aAdd( aStruct, { 'INTSOC','C', 001, 0 } )
	aAdd( aStruct, { 'EMPLEA','C', 001, 0 } )
	aAdd( aStruct, { 'ACTMON','C', 002, 0 } )
 
    FWDBCreate( 'PADRSC', aStruct , 'TOPCONN' , .T.)
	
	oFile := ZFWReadTXT():New(cFile,CHR(10),_BUFFER)
	If !oFile:Open()
		MsgAlert(STR0032 + cFile + STR0033)  //"El archivo " +cArqProc+ "No puede abrirse"
		Return .F.
	EndIf 
   
	oBulk := FwBulk():New('PADRSC',1200)
    lCanUseBulk := FwBulk():CanBulk() // Este m�todo n�o depende da classe FWBulk ser inicializada por NEW
    If lCanUseBulk
        oBulk:SetFields(aStruct)
    Endif
	If lCanUseBulk		 
		While oFile:ReadLine(@cDatos)
			aDatos := SeperaStr(cDatos) 
			oBulk:AddData({aDatos[1],aDatos[2],aDatos[3],aDatos[4],aDatos[5],aDatos[6],aDatos[7],aDatos[8]}) 
			aSize(aDatos,0)				
		EndDo
		lProc := .T.
	Endif
	oFile:Close()	 // Fecha o Arquivo 
	FT_FUSE()
    If lCanUseBulk
        oBulk:Close()
        oBulk:Destroy()
        oBulk := nil
    Endif
	MsgAlert(STR0028)	
Return lProc 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  PrcFisa102 Autor �Marivaldo Bezerra         � Data �.12.2020 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que mostra o status de processamento da cria��o dos  ���
���           registro no banco de dados                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�����������������������������������������������������������������������������
/*/
Static Function PrcFisa102(lRetOk)

Default lRetOk := .F. 

	MsAguarde({|lRetOk| ProArqu(@lRetOk)},STR0030,STR0031)

Return 


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ProArqu � Autor �Marivaldo Bezerra          � Data �.12.2020���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Fun��o que faz a criacao do arquivo temporario no banco de  ���
���           dados                                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�����������������������������������������������������������������������������
/*/
Static Function ProArqu(lRetOk)
    
Default lRetOk := .F.

 lRetOk :=ProsArqu()   
 
Return lRetOk