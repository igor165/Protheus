#INCLUDE "protheus.ch"
#INCLUDE "TopConn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
����������������������-��������������������������������������������������Ŀ��
���Fun�ao    �GH149550  � Autor � MICROSIGA             � Data � 04/07/08 ���
�����������������������-�������������������������������������������������Ĵ��
���Descri�ao � Funcao Principal                                           ���
������������������������-������������������������������������������������Ĵ��
���Uso       � Gestao Hospitalar                                          ���
������������������������-�������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function GH149550()

cArqEmp 					:= "SigaMat.Emp"
__cInterNet 	:= Nil

PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}                                            
PRIVATE oMainWnd
Private nModulo 	:= 51 // modulo SIGAHSP

Set Dele On

lEmpenho				:= .F.
lAtuMnu					:= .F.
		 	
Processa({|| ProcATU()},"Processando [GH149550]","Aguarde , processando prepara��o dos arquivos")

Return()


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ProcATU   � Autor �                       � Data �  /  /    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de processamento da gravacao dos arquivos           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Baseado na funcao criada por Eduardo Riera em 01/02/2002   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ProcATU()
Local cTexto    	:= Time() + Chr(13) + Chr(10)
Local cFile     	:= ""
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    	:= 0
Local nI        	:= 0
Local nX        	:= 0
Local aRecnoSM0 	:= {}
Local lOpen     	:= .F.

ProcRegua(1)       



IncProc("Verificando integridade dos dicion�rios....")
If (lOpen := IIF(Alias() <> "SM0", MyOpenSm0Ex(), .T. ))

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf			
		dbSkip()
	EndDo	

	If lOpen
			                     
		If !Hs_AtuGAV(@cTexto)
   Return(.F.)
  EndIf

	EndIf
		
EndIf 	

	


Return(Nil)


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MyOpenSM0Ex� Autor �Sergio Silveira       � Data �07/01/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a abertura do SM0 exclusivo                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao FIS                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	openSM0( cNumEmp,.F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")
		Exit	
	EndIf
	Sleep( 500 )
Next nLoop

If !lOpen
	Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 )
EndIf

Return( lOpen )

Function Hs_AtuGAV(cTexto)
 Local aRecnoSM0 := {}
 Local nI := 0
 Local lRet := .T. 
Local cFile     	:= ""
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
 
 
 lOpen := IIF(Alias() <> "SM0", MyOpenSm0Ex(), .T. )

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO .And. x[3] == M0_CODFIL}) == 0
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO, M0_CODFIL})
		EndIf			
		dbSkip()
	EndDo	

 For nI := 1 To Len(aRecnoSM0)
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			RpcSetType(2)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
 		nModulo := 51 // modulo SIGAHSP
			lMsFinalAuto := .F. 
			
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Fun��es descontinuadas pelo SGBD: GeraSX6() E GeraSX1()" , 0, 0, {})
			
			If MsgYesNo("Executar ajuste na tabela GB1?"+ " Filial : " + SM0->M0_CODFIL + " - " + SM0->M0_FILIAL)
			
 
				
 			cTexto += Replicate("-",128)+CHR(13)+CHR(10)
 			cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+SM0->M0_FILIAL+CHR(13)+CHR(10)+CHR(13)+CHR(10)
 			cTexto += "Data/Hora de sa�da incompat�veis" + CHR(13) + CHR(10)

    Processa({|| lRet := Fs_AtuGAV(@cTexto)}) 
   
   EndIf
   
   If !lRet 
    RpcClearEnv()
    Return(lRet)
   End 
      
   RpcClearEnv()	
			If !( lOpen := MyOpenSm0Ex() )
				Exit
		 EndIf
	Next nI
	 
Return(lRet)  

Static Function Fs_AtuGav(cTexto)
 Local cSql   := ""
 Local nRecNoOld  := 0, dDataSAte := CTOD("  /  /  "), dHoraSAte := ""
 Local lExc := .F.
 Local cFile     	:= ""
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"

 
 DbSelectArea("GB1")
  
 //Seleciona todos os registros que est�ao com problema
 //Data de sa�da em branco
 cSql := "SELECT GCY.GCY_REGATE "
 cSql += "FROM   " + RetSqlName("GB1") + " GB1 "
 cSql += "  JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_REGATE = GB1.GB1_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSql += "WHERE GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_DATAS = '" + SPACE(Len(DTOS(GB1->GB1_DATAS))) + "' AND "
 cSql += "  GB1.GB1_REGATE NOT IN (SELECT GAV_REGATE "
 cSql += "                  					   FROM " + RetSqlName("GAV") + " GAV1 "
 cSql += "			                  		   WHERE GAV1.GAV_CODLOC = GB1.GB1_CODLOC AND GAV1.GAV_QUARTO = GB1.GB1_QUARTO AND GAV1.GAV_LEITO = GB1.GB1_LEITO "
 cSql += "                            AND GAV1.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV1.D_E_L_E_T_ <> '*' ) "
 cSql += "GROUP BY GCY.GCY_REGATE "
 cSql += "ORDER BY GCY.GCY_REGATE "

 cSQL := ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRYATU"
 DbSelectArea("QRYATU")
 
 While !QRYATU->(Eof())

  //Seleciona todas as movimenta��es de leito para cada registro (atendimento) acima
  cSql := "SELECT GB1.GB1_FILIAL, GB1.GB1_REGATE, GB1.GB1_CODLOC, GB1.GB1_QUARTO, GB1.GB1_LEITO, GB1.R_E_C_N_O_ GB1REC, GCY.GCY_DATATE, GB1.GB1_DATAE, "
  cSql += "       GB1.GB1_HORAE, GB1.GB1_DATAS, GB1.GB1_HORAS, GCY.GCY_DATSAI, GCY.GCY_HORSAI, GB1.GB1_LOGSAI, GB1.GB1_LOGENT "
  cSql += "FROM   " + RetSqlName("GB1") + " GB1 "
  cSql += "  JOIN " + RetSqlName("GCY") + " GCY ON GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND "
  cSql += "   GCY.GCY_REGATE = GB1.GB1_REGATE "
  cSql += "  JOIN " + RetSqlName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND "
  cSql += "   GAV.GAV_TIPO <> '2' AND GAV.GAV_QUARTO = GB1.GB1_QUARTO AND GAV.GAV_LEITO = GB1.GB1_LEITO "
  cSql += "WHERE GB1.GB1_REGATE = '" + QRYATU->GCY_REGATE + "' AND GB1.D_E_L_E_T_  <> '*' AND GB1.GB1_FILIAL = '" + xFilial("GB1") + "' "
  If "MSSQL" $ TcGetDb()
  	cSql += "ORDER BY GB1.GB1_DATAE, RIGHT(GB1_LOGENT,9)"
	 Else
	 	cSql += "ORDER BY GB1.GB1_DATAE, SUBSTR(GB1_LOGENT,32,9)" 
  EndIf
  
  cSQL := ChangeQuery(cSQL)

  TCQUERY cSQL NEW ALIAS "TMPGB1"
  DbSelectArea("TMPGB1")
  
  If !TMPGB1->(EOF())
  
   nRecNoOld  := TMPGB1->GB1REC

   DBSkip()
  
   While !TMPGB1->(EOF())
    
    DbSelectArea("GB1")   
    DBGoTo(nRecNoOld)
    
    Begin Transaction
     
     RecLock("GB1", .F.)
      GB1->GB1_DATAS := STOD(TMPGB1->GB1_DATAE)
      GB1->GB1_HORAS := TMPGB1->GB1_HORAE
     MsUnLock()
    
    End Transaction
    
    nRecNoOld := TMPGB1->GB1REC
    dDataSAte := STOD(TMPGB1->GCY_DATSAI) // ser� usado apenas pro �ltimo
    dHoraSAte := TMPGB1->GCY_HORSAI       // ser� usado apenas pro �ltimo 
    
    TMPGB1->(DBSkip())
   
   End
  
   //�ltimo registro do movimenta��o tem tratamento diferenciado
   //Se J� tiver dado sa�da ser� gravada a data e hora de sa�da do atendimento
   DbSelectArea("GB1")   
   DBGoTo(nRecNoOld)
   
   If dDataSAte < GB1->GB1_DATAS .Or. (dDataSAte == GB1->GB1_DATAS .And. GB1->GB1_HORAS < dHoraSAte)
  
    cTexto += "Atendimento " + GB1->GB1_REGATE + CHR(13) + CHR(10)

   Else
    
    Begin Transaction
     RecLock("GB1", .F.)
      GB1->GB1_DATAS := dDataSAte
      GB1->GB1_HORAS := dHoraSAte
     MsUnLock()
    End Transaction
    
    dDataSAte := CTOD("  /  /  ")
    dHoraSAte := ""
    
   EndIf
   
   //Exclus�o dos registros
   DbSelectArea("TMPGB1")
   DbGotop()
   
   nRecPri  := TMPGB1->GB1REC
   
   While !TMPGB1->(EOF())
   
    lExc := .F.
    
    DbSelectArea("GB1")
    DbGoto(nRecPri)//Posiciona na primeira movimenta��o de leito da sequ�ncia de repeti��es
    
    TMPGB1->(DBSkip())   
    
    While  !TMPGB1->(EOF()) .And. TMPGB1->GB1_CODLOC == GB1->GB1_CODLOC .And. TMPGB1->GB1_QUARTO == GB1->GB1_QUARTO .And.;
            TMPGB1->GB1_LEITO == GB1->GB1_LEITO
     
     lExc := .T. //Excluiu algum registro
     Begin Transaction
      
      DbSelectArea("GB1")
      RecLock("GB1", .F.) //Grava data e hora do atual no primeiro
       GB1->GB1_DATAS := STOD(TMPGB1->GB1_DATAS)
       GB1->GB1_HORAS := TMPGB1->GB1_HORAS
      MsUnlock()
      
      DbGoto(TMPGB1->GB1REC) // Posiciona no atual e exclui
      RecLock("GB1", .F.)
       DbDelete()
      MsUnlock()
     
     End Transaction
     
     DbSelectArea("GB1")
     DbGoto(nRecPri)//Re-Posiciona na primeira movimenta��o de leito da sequ�ncia de repeti��es
     
     TMPGB1->(DbSkip())
         
    End
    
    nRecPri  := TMPGB1->GB1REC
    
   End
  
  EndIf
  
  TMPGB1->(DbCloseArea())
  
  QRYATU->(DBSkip())
 End

 QRYATU->(DbCloseArea())
 DbSelectArea("SX3") 
 
 
  cTexto    	+= Time() + Chr(13) + Chr(10)

 	cTexto 				:= "Log da atualizacao " + CHR(13) + CHR(10) + cTexto
		__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)
		
		DEFINE FONT oFont NAME "Mono AS" SIZE 8,10
		DEFINE MSDIALOG oDlg TITLE "Atualizador [GH149550] - Atualizacao concluida." From 3,0 to 340,417 PIXEL
			@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		ACTIVATE MSDIALOG oDlg CENTER
	 
Return(.T.)
