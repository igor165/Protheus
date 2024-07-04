#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "TBICONN.CH"
#Include "GPER991.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � GPER991 � Autor � Cristian Franco       � Data �  24/02/20 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprimir Aviso de Vacaciones                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GPER991()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPER991()
			
	Local   oPrinter
	Local   cQuery 		:= ""
	Local	cSuc   		:= ""   
	Local	cMat   		:= ""
	Local	cCet   		:= ""
	Local	dDate		:= CTOD("  /  /  ") 
	Local	dAdate		:= CTOD("  /  /  ") 
	Local	cArea		:=""
	Local 	nTipRel		:=0
	Local 	nResImpr 	:= 0 				// resultado de impresi�n
	Local   lEnvOK 		:= .F.
	Local 	nI			:=0
	Local   cEmailCli	:= ""
	Private dFechaIn 	:= CTOD("  /  /  ")
	Private dFechaFin 	:= CTOD("  /  /  ")
   	Private lImpre		:= .F. 
	Private cTitulo		:="" 
	Private nAux01		:=""
	Private cNome		:=""
	Private nDuracao 	:=0
	Private nDur		:=0
	Private aInfSRA		:={}
	Private aInfSR8		:={}
	Private cAliasBus	:= GetNextAlias()
	Private cAliasTmp	:= GetNextAlias()
	Private dDataAnt	:= CTOD("  /  /  ")
	Private dDataFin	:= CTOD("  /  /  ")
	Private aDataAlt	:= ""
	Private cMesDia		:= ""
	Private cNumID		:= ""
	Private cAnioIni	:= "" 
	Private cMesIni		:= ""  	
	Private cDiaIni		:= "" 
	Private cAnioFim	:= "" 
	Private cMesFim		:= ""  	
	Private cDiaFim		:= "" 
	Private aEmail 		:={}
	Private li			:= _PROW()
	Private lPDFEmail	:= .T.
	Private aItens 		:= {}
	Private cFileGen 	:= ""
	Private cPath		 := GetSrvProfString('RootPath','\') //+ 'System\spool\' 
	Private patEmail	:=GetSrvProfString('startpath','\')
	
	//cPath := Replace( cPath, "\\", "\" )
   
	If pergunte("GPER991",.T.)
	
		//convierte parametros tipo Range a expresion sql
		//si esta separa por "-" agrega un BETWEEN,  si esta separado por ";" agrega un IN
		MakeSqlExpr("GPER991")
		dDate:= (MV_PAR01) //De Fecha
		dAdate:= (MV_PAR02) //A fecha 
		nTipRel:= (MV_PAR03)// Impresso / eMail
		cSuc := Trim(MV_PAR04) //�Sucursal ?
		cCet := Trim(MV_PAR05) //�Centro de Trabajo ?
		cArea:= Trim(MV_PAR06) //Area
		cMat := Trim(MV_PAR07) //�Matricula ?	
		
							    
		//���������������������������������������������Ŀ
		//� Selecciona los datos de la tabla SR8 Y RCM  �
		////�����������������������������������������������		
 		cQuery  += "SELECT *"
		cQuery  += " FROM " + RetSqlName( "SR8" ) + " SR8,"+RetSqlName("RCM") + " RCM, "+RetSqlName("SRA") + " SRA "
		cQuery  += " WHERE R8_TIPOAFA = RCM.RCM_TIPO "
		cQuery  +=	"AND SRA.D_E_L_E_T_=' ' "
		cQuery  +=	"AND SR8.D_E_L_E_T_=' ' "
		cQuery  +=	"AND RCM.D_E_L_E_T_=' ' "
		cQuery  += " AND R8_FILIAL='"+XFILIAL("SR8")+" ' "
		cQuery  += " AND RCM_FILIAL='"+XFILIAL("RCM")+" ' "
		cQuery  += " AND RA_FILIAL='"+XFILIAL("SRA")+" ' "
		cQuery  += " AND R8_MAT = RA_MAT"
		cQuery  += " AND R8_DATAINI BETWEEN '"+DTOS(dDate)+ "' AND '"+DTOS(dAdate)+"'"
		cQuery  += " AND RCM_TPIMSS='3'"
		If	!Empty( cSuc )
			cQuery  += " AND "+cSuc+""
		EndIf
		If	!Empty( cCet )	
			cQuery  += " AND "+cCet+""
		EndIf
		If	!Empty( cArea )
		cQuery  += " AND "+cArea+""
		EndIf
		If	!Empty( cMat )
			cQuery  += " AND "+cMat+""
		EndIf
		cQuery  := StrTran( cQuery, ";", "" )  	
		
		cQuery := ChangeQuery(cQuery)
    	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasBus, .T., .F. )		
    	
    	TcSetField(cAliasBus,"R8_DATAINI"  ,"D")
    	TcSetField(cAliasBus,"R8_DATAFIM"  ,"D")
    	cFileGen	:= STR0020
  	
		//���������������������������������������������Ŀ
		//� se inicializa el objeto FWMSPrinter 		  �
		//� solo si hay registros para procesar		  �
		//�����������������������������������������������
		oPrinter      	 := FWMSPrinter():New(cFileGen,6,.F.,GetClientDir(),.T.,,,,,.F.) //inicializa el objeto
		oPrinter:Setup() 				    	//abre el objeto
		oPrinter:setDevice( IMP_PDF )   		//selecciona el medio de impresi�n
		oPrinter:SetMargin(40,10,40,10) 	//margenes del documento
		oPrinter:SetPortrait()           	//orientaci�n de p�gina modo retrato =  Horizontal
		nResImpr := oPrinter:nModalResult 	//obtiene nModalResult=1 confimada --- nModalResult=2 cancelada 
		
			
		While (cAliasBus)->(!EOF())
		 	aInfSRA := {(cAliasBus)->RA_SEXO,(cAliasBus)->RA_ESTCIVI,(cAliasBus)->RA_PRINOME,(cAliasBus)->RA_SECNOME,(cAliasBus)->RA_PRISOBR,(cAliasBus)->RA_SECSOBR,(cAliasBus)->RA_TPCIC,(cAliasBus)->RA_CIC}
			aInfSR8 :={(cAliasBus)->R8_DURACAO,(cAliasBus)->R8_DATAINI,(cAliasBus)->R8_DATAFIM}
				
			cAnioIni	:= YEAR (aInfSR8[2])
			cMesIni		:= MESEXTENSO(MONTH(aInfSR8[2]))
			cDiaIni		:= DAY (aInfSR8[2])
			cAnioFim	:= YEAR (aInfSR8[3])
			cMesFim		:= MESEXTENSO(MONTH(aInfSR8[3]))
			cDiaFim		:= DAY(aInfSR8[3])
			dDataFin	:= aInfSR8[3] + 1		
			dDataAnt	:= aInfSR8[2]-1
			
			If DOW(dDataFin) == 7
				dDataFin 	:= dDataFin+2
			ElseIf	DOW(dDataFin) == 1
				dDataFin 	:= dDataFin+1
			EndIf
			If DOW(dDataAnt) == 1
				dDataAnt	:= dDataAnt-2
			EndIf	
			cMesDia:= StrZero(MONTH(dDataFin),2)+StrZero(DAY(dDataFin),2)	
			
			If aInfSRA[1]="F" .and. aInfSRA[2]="S"
				cTitulo="Se�orita"
			EndIf
			If aInfSRA[1]="F" .and. aInfSRA[2] <> "S"
				cTitulo="Se�ora"
			EndIf
			If aInfSRA[1]="M" 
				cTitulo="Se�or"
			EndIf 		
			
			cNome := ALLTRIM(aInfSRA[3])+" "+ALLTRIM(aInfSRA[4])+" "+ALLTRIM(aInfSRA[5]) + " " +ALLTRIM(aInfSRA[6])			
			
			//���������������������������������������������Ŀ
			//� Selecciona los datos de la tabla SRF		  �
			////�����������������������������������������������	
			cQuery	:= ""
			cQuery  += " SELECT * "
			cQuery  += " FROM " + RetSqlName( "SRF" ) + " SRF"
			cQuery  += " WHERE RF_MAT='"  +(cAliasBus)->R8_MAT+"'"
			cQuery  += " AND RF_STATUS='1' " 
			cQuery  += " AND SRF.D_E_L_E_T_=' ' "
			cQuery  += " AND RF_FILIAL='"+XFILIAL("SRF")+" ' "
			cQuery  += " ORDER BY RF_DATABAS " 	
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .F. ) 
			
			TcSetField(cAliasTmp,"RF_DATABAS"  ,"D")
			TcSetField(cAliasTmp,"RF_DATAFIM"  ,"D")
			
			dFechaIn	:= (cAliasTmp)->RF_DATABAS
			dFechaFin	:= (cAliasTmp)->RF_DATAFIM
			nDuracao	:= (cAliasBus)->R8_DURACAO
			
			While (cAliasTmp)->(!EOF())
				nSaldo		:= (cAliasTmp)->RF_DFERVAT + (cAliasTmp)->RF_DFERAAT - (cAliasTmp)->RF_DFERANT			
					If nDuracao		<= nSaldo
						dFechaFin	:= (cAliasTmp)->RF_DATAFIM
						Exit 
					Else
						nDuracao	:= nDuracao - nSaldo
					EndIf
				
		    	(cAliasTmp)->(dbSkip())
			EndDo
			(cAliasTmp)->(dbCloseArea())
				lImpre := .T.					   		    		
				ImpPagVac(oPrinter)
    		(cAliasBus)->(dbSkip())	
		EndDO
				If nTipRel ==1	
					oPrinter:Preview() 
				EndIf 
				
				cFileAux := GetClientDir()  + cFileGen +".pdf"
				
				If nTipRel ==2			
					oPrinter:SetViewPDF( .F.)
					oPrinter:Print()
					CpyT2S("C:\\"+cFileGen+".pdf", patEmail)
					aFileAux := {}
					aItens := {}								
					aAdd( aItens, patEmail + cFileGen + ".pdf" ) 
					
					cFile := patEmail + cFileGen + ".zip"
					&('FZip(cFile,aItens, patEmail)')
					
					aAdd(aFileAux, StrTran( upper(patEmail + cFileGen + ".zip"), upper(GetSrvProfString('rootpath','')))) 
					cEmailCli := ObtEmail((cAliasBus)->RA_MAT) 
					lEnvOK := EnvioMail(cEmailCli,aFileAux)	
					
					For nI := 1 To Len(aFileAux)
						FErase(aFileAux[nI])
					Next nI		
				EndIf 	
	EndIf
		
return   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ImpPagVac � Autor � Cristian Franco      � Data � 24/02/2019���
�������������������������������������������������������������������������Ĵ��
���Descri��o � �Imprime Aviso de Vacaciones             				  ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpPagVac()                                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���                 													  ���
�������������������������������������������������������������������������Ĵ��
���			   �		�      �            							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ImpPagVac(oPrintDoc)
			
	Local oPrinter
	Local oFontT			
	Local oFontP
	Local aLinea	:= {} 
	Local nSalto  	:= 0	
	Local nEsp  	:= 0	
	Local nX  		:= 0 
	Local cValInL	:= ""
	Local cStartPath	:= GetSrvProfString("Startpath","")

		oPrinter   := oPrintDoc
		cValInL	:= space(90)
		cLineas	:= space(50)							 
		oFontT 		:= TFont():New('Arial',,-15,.T.,.T.)//Fuente del Titulo
		oFontP 		:= TFont():New('Arial',,-14,.T.)     //Fuente del P�rrafo
			oPrinter:StartPage() 
			nEsp := 90 			
			oPrinter:SayBitmap(030,060,cStartPath+"lgrl"+FwCodEmp("SM0")+".bmp",80,40)
			oPrinter:Say(nEsp,200,STR0018,oFontT) // agrega el titulo
			//Llena array que contendr� la posici�n vertical de las l�neas del formato de impresi�n
			For nX=1 to 18 step 1
				nSalto := 20				
				If nX==1   
					nSalto := 80
				EndIf
				If  nX==8 .Or. nX ==9 
					nSalto := 30
				EndIf
				If nX==4 .Or. nX ==13
					nSalto := 60
				EndIf
				If nX==11  .Or. nX==14
					nSalto := 70
				EndIf
				nEsp = nEsp + nSalto
				AADD(aLinea, nEsp)
			Next	
			
			oPrinter:Say(aLinea[1],  70, cTitulo , oFontP)			
			oPrinter:Say(aLinea[2],  70, cNome, oFontP)
			oPrinter:Say(aLinea[3],  70, STR0001 , oFontP)
			
			If ExistBlock("GPE991")  // Punto de entrada para Actualizar fecha de regreso
				dDataFin:= ExecBlock("GPE991",.F.,.F.,{dDataFin})
			EndIf
			
			If VerifDia(cMesDia,dDataFin)
				dDataFin := dDataFin+1
			EndIf	
			oPrinter:Say(aLinea[4],  130, STR0002, oFontP)
			oPrinter:Say(aLinea[5],   70, STR0003 + STR0004, oFontP)
			oPrinter:Say(aLinea[6],   70, ALLTRIM(STR(nDuracao))+ STR0005+ DIASEMANA(aInfSR8[2])+ Alltrim(STR(cDiaIni)) +STR0007+cMesIni+STR0007+Alltrim(STR(cAnioIni))+STR0034+DIASEMANA(aInfSR8[3])+Alltrim(STR(cDiaFim))+STR0007, oFontP,200)
			oPrinter:Say(aLinea[7],   70, cMesFim+STR0007+Alltrim(STR(cAnioFim))+STR0008+STR0009+ DTOC(dFechaIn)+STR0010+ DTOC(dFechaFin)+STR0012, oFontP)
			oPrinter:Say(aLinea[8],   70, STR0011+DIASEMANA(dDataFin)+ " " + Alltrim(STR(DAY(dDataFin))) + STR0007+MESEXTENSO(MONTH(dDataFin))+STR0007+ Alltrim(STR(YEAR(dDataFin)))+STR0012, oFontP)
			oPrinter:Say(aLinea[9],   70, STR0019 , oFontP)
			oPrinter:Say(aLinea[10],  70,STR0036 , oFontP)
			oPrinter:Say(aLinea[11],  200,STR0016, oFontP)
			oPrinter:Say(aLinea[12],  235,STR0037, oFontP)		
			oPrinter:Say(aLinea[13],  250,STR0017, oFontP)
			oPrinter:Say(aLinea[14],  200,STR0016, oFontP)
			oPrinter:Say(aLinea[15],  200,cNome, oFontP)
			oPrinter:Say(aLinea[16],  250,ALLTRIM(aInfSRA[7])+"  "+ALLTRIM(aInfSRA[8]), oFontP)
		
		oPrinter:EndPage() // Finaliza la p�gina
		
							
return 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � EnvioMail  � Autor � Cristian Franco       � Data � 24.02.20 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � EnvioMail(cEmailC, aAnexo)                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cEmailC .- Email del empleado para envio de archivo  PDF.    ���
���          � aAnexo .- Arreglo con archivos adjuntos.                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lResult .- Valor l�gico .T. envio exitoso, .F. error de envio���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPER991                                                		���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function EnvioMail(cEmailC, aAnexo)
	Local lResult 	:= .F.
	Local cServer	:= GetMV("MV_RELSERV",,"" ) //Nombre de servidor de envio de E-mail utilizado en los informes.
	Local cEmail	:= GetMV("MV_RELACNT",,"" ) //Cuenta a ser utilizada en el envio de E-Mail para los informes
	Local cPassword	:= GetMV("MV_RELPSW",,""  ) //Contrasena de cta. de E-mail para enviar informes
	Local lAuth		:= GetMv("MV_RELAUTH",,.F.)	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
	Local lUseSSL	:= GetMv("MV_RELSSL",,.F.)	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
	Local lTls		:= GetMV("MV_RELTLS",,.F.)	//Informe si el servidor de SMTP tiene conexion del tipo segura ( SSL/TLS ).    
	Local nPort		:= GetMv("MV_SRVPORT",,0)	//Puerto de conexion con el servidor de correo
	Local nErr		:= 0
	Local ctrErr	:= ""
	Local oMailServer := Nil
	Local cAttach  := ""
	Local nI 	:= 0
	Local cMsg	:= ""
	Local nX	:= 0
	
	If Empty(cServer)
		cMsg += STR0021 + STR0022 + CHR(13) + CHR(10) //"Configure par�metro " "MV_RELSERV" 
	EndIf	
	If Empty(cEmail)
		cMsg += STR0021 + STR0023 + CHR(13) + CHR(10) //"Configure par�metro " "MV_RELACNT"
	EndIf	
	If Empty(cPassword)
		cMsg += STR0021 + STR0024 + CHR(13) + CHR(10) // "Configure par�metro " "MV_RELPSW"
	EndIf
	If Empty(cEmailC)
		cMsg += STR0025 + CHR(13) + CHR(10) // "Configure email del cliente."
	EndIf
	
	If !empty(cMsg)
		return .F.
	EndIf
	
	If !Empty(cEmailC)
		For nI:= 1 to Len(aAnexo)
			cAttach += aAnexo[nI] + "; "
		Next nI	

		If !lAuth .And. !lUseSSL .And.!lTls
			CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPassword RESULT lResult
			
			If lResult 
				SEND MAIL FROM cEmail ;
				TO      	cEmailC;
				BCC     	"";
				SUBJECT 	STR0032;
				BODY    	STR0033;
				ATTACHMENT  cAttach  ;
				RESULT lResult

				If !lResult
					//Erro no envio do email
					GET MAIL ERROR cError
					Help(" ",1,STR0026,,cError,4,5)
				EndIf

			Else
				//Erro na conexao com o SMTP Server
    			GET MAIL ERROR cError                                       
    			Help(" ",1,STR0026,,cError,4,5) //--- Aviso    

			EndIf

			DISCONNECT SMTP SERVER
		Else
			//Instancia o objeto do MailServer
			oMailServer:= TMailManager():New()
			oMailServer:SetUseSSL(lUseSSL)    //Obs: Apenas se servidor de e-mail utiliza autenticacao SSL para envio
			oMailServer:SetUseTLS(lTls)       //Obs: Apenas se servidor de e-mail utiliza autenticacao TLS para recebimento

			If Empty(nPort)
				oMailServer:Init("",cServer,cEmail,cPassword,0)
			Else
				oMailServer:Init("",cServer,cEmail,cPassword,0,nPort)
			EndIf
		                               
		    //Defini��o do timeout do servidor
			If oMailServer:SetSmtpTimeOut(120) != 0
		   		Help(" ",1,STR0029,,OemToAnsi(STR0030) ,4,5) //"Aviso" ## "Tiempo de Servidor"
		   		Return .F.
		   	EndIf
		
		   	//Conex�o com servidor
		   	nErr := oMailServer:smtpConnect()
		   	If nErr <> 0
		   		cTrErr:= oMailServer:getErrorString(nErr)
		    	oMailServer:smtpDisconnect()
		    	
		    	// Intenta (varias veces) el env�o a trav�s de otra clase de conexi�n
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, aAnexo, @cTrErr)
		    	
		    	If !lResult
			   		Help(" ",1,STR0026,,ctrErr,4,5) 
				EndIf

				Return lResult
		   	EndIf

		   	//Autentica��o com servidor smtp
		   	nErr := oMailServer:smtpAuth(cEmail, cPassword)
		   	If nErr <> 0
		    	cTrErr := OemToAnsi(STR0031) + CRLF + oMailServer:getErrorString(nErr)
		     	oMailServer:smtpDisconnect()

		    	// Intenta (varias veces) el env�o a trav�s de otra clase de conexi�n
		    	lResult := EnvioMail2(cServer, cEmail, cPassword, lAuth, cEmailC, aAnexo, @cTrErr)
		    	
		    	If !lResult
			     	Help(" ",1,STR0029,,cTrErr ,4,5)//"Aviso" ## "Autenticaci�n con servidor smtp"
				EndIf

				Return lResult
		   	EndIf
		                               
		   	//Cria objeto da mensagem+
		   	oMessage := tMailMessage():new()
		   	oMessage:clear()
		   	oMessage:cFrom 	:= cEmail 
		   	oMessage:cTo 	:= cEmailC 
		   	oMessage:cSubject :=  STR0032
		   	oMessage:cBody := STR0033

		   	For nX := 1 to Len(aAnexo)
		   		oMessage:AddAttHTag("Content-ID: <" + aAnexo[nX] + ">") //Essa tag, � a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		     	oMessage:AttachFile(aAnexo[nX])                       //Adiciona um anexo, nesse caso a imagem esta no root
		   	Next nX
		                               
			//Dispara o email          
			nErr := oMessage:send(oMailServer)
			If nErr <> 0
		   		cTrErr := oMailServer:getErrorString(nErr)
		     	Help(" ",1,STR0029,,OemToAnsi(STR0026) + CRLF + cTrErr ,4,5)//"Aviso" ## "Error en el Envio del Email"
		     	oMailServer:smtpDisconnect()
		     	Return .F.
			Else
		   		lResult := .T.
		   	EndIf
		
		  	//Desconecta do servidor
		   	oMailServer:smtpDisconnect()
		EndIf
	EndIf
Return lResult	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ObtEmail   � Autor � Cristian Franco       � Data � 24.02.20 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ObtEmail(cMat)                                    			���
���������������������������������������������������������������������������Ĵ��
���Parametros� cMat .- Matr�cula de Empleado.                               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cEmailCli .- Email configurado para empleado (RA_EMAIL).     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � GPERP991                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ObtEmail(cMat)
	Local cEmailCli := ""
	Local aArea 	:= getArea()
	dbSelectArea("SRA")
	SRA->(dbSetOrder(1)) //RA_FILIAL+RA_MAT                                                                                                                                                 
	If SRA->(dbSeek(xFilial("SRA") + cMat ))
		cEmailCli := SRA->RA_EMAIL
	EndIf
	RestArea(aArea)	
Return cEmailCli

/*/{Protheus.doc} EnvioMail2
//TODO Descri��o auto-gerada.
@author arodriguez
@since 10/01/2020
@version 1.0
@return l�gico, env�o correcto?
@param cMailServer, characters, direcci�n de servidor de correo
@param cMailConta, characters, usuario de conexi�n / cuenta de correo remitente
@param cMailSenha, characters, contrase�a del usuario
@param lAutentica, logical, requiere autenticaci�n?
@param cEmail, characters, correo destinatario (cliente)
@param cEMailAst, characters, asunto
@param cMensGral, characters, contenido
@param aAnexo, array, array de anexos
@param cErr, characters, (@referencia) variable para mensaje de error
@type function
/*/
Static Function EnvioMail2(cMailServer, cMailConta, cMailSenha, lAutentica, cEmail, cEMailAst, cMensGral, aAnexo, cErr)
	Local cAcAut	:= GetMV("MV_RELAUSR",,"" )		//Usuario para autenticacion en el servidor de email
	Local cPwAut 	:= GetMV("MV_RELAPSW",,""  )	//Contrase�a para autenticacion en servidor de email
	Local lResult	:= .F.
	Local nIntentos	:= 0

	If lAutentica .And. Empty(cAcAut+cPwAut)
		Return lResult
	EndIf

	Do While !lResult .And. nIntentos < 11
		nIntentos++
		lResult := MailSmtpOn(cMailServer,cMailConta,cMailSenha)

		// Verifica se o E-mail necessita de Autenticacao
		If lResult .And. lAutentica
			lResult := MailAuth(cAcAut,cPwAut)
		Endif

		If lResult
			lResult := MailSend(cMailConta, {cEmail}, {" "}, {" "}, cEMailAst, cMensGral, aAnexo)
		EndIf

		If !lResult
			cErr := MailGetErr()
		EndIf

		MailSmtpOff()
	EndDo

Return lResult
//+----------------------------------------------------------------------+
//|Verifica si existen d�as feriados           |
//+----------------------------------------------------------------------+
//|Autor	| Cristian Franco   												 | 
//+-------------+--------------------------------------------------------+
Static Function VerifDia(cMesDia,dDataFin)
Local cQuery	:= ""
Local cTmpDia	:= GetNextAlias()
Local lRet		:= .F.
Local cDataFin	:= ""
	cDataFin:= DTOS(dDataFin)
	cQuery 	:= 	"SELECT "
	cQuery	+=	"P3_FILIAL,P3_DATA,  "
	cQuery	+=	"P3_FIXO,P3_MESDIA "
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName("SP3")+ " SP3 "
	cQuery	+=	"WHERE "
	cQuery	+=	"(P3_MESDIA='"+cMesDia+"' "
	cQuery  +=  "OR P3_DATA= '"+cDataFin+"') AND P3_FILIAL='"+XFILIAL("SP3")+" ' "
	cQuery	+=  "AND SP3.D_E_L_E_T_= ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpDia,.T.,.T.)

	If (cTmpDia)-> (!Eof()) 
		While (cTmpDia)-> (!Eof()) 
			If !Empty((cTmpDia)->P3_MESDIA) .OR. !Empty((cTmpDia)->P3_DATA)
				lRet := .T.
			EndIf
			(cTmpDia)->(dbSkip())
		Enddo
	Else
		lRet := .F.
	EndIf
Return lRet

	
