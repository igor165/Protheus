#include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FisLoad   �Autor  �Mary C. Hergert     � Data �  04/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faz a chamada de funcoes que devem ser processas na entrada ���
���          �do modulo                                                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/
Function FisLoad()      

Local olProcess	:= NIL     
Local llProcess	:= .F. 
Local nlCont	:= 0          
Local nlQtdReg	:= 0   
Local alArea	:= {}
Local alTabelas	:= {"CC2","CC4","CC5","CC6","CC8","CC9","CCA","CCB","CCC","CCD","CCH","CCK","CDO","CDY"}
Local cDirFiles	:= GetSrvProfString("Startpath","") + "arqsped\"
Local cDirProf	:= GetSrvProfString("RootPath","") + "profile\"
Local cArqBkp	:= ""
Local nHdl	    :=	0
Local aAreaSX5	:=	{}         
Private lBuild  :=	GetBuild() >=  "7.00.170117A-20180803" 

If cPaisLoc $ "PER"		
	CRIASED()
EndIf

If cPaisLoc $ "COL"
	CIIUCOL()
EndIf                    

If cPaisLoc == "BRA"  
	
	//Ir� verificar se usu�rio j� logo no m�dulo SIGAFIS ao menos uma vez no dia para definir se exibe ou n�o o banner, caso o build n�o seja LG	
	If ! lBuild .and. !IsBlind() .And. FisChkBan(RetCodUsr(),'FISLOAD', 'HOMEFISCAL', dtos(date())) 
		//Carrega Banner ao entrar no m�dulo Fiscal pela primeira vez no Dia
		FisLoadBan("http://tdn.totvs.com/plugins/servlet/remotepageview?pageId=286737675","Boletim Fiscal")
	EndIf

	//�������������������������������������������������������������Ŀ
	//� Verifica se existe o diretorio ARQSPED dentro da StartPath  �
	//��������������������������������������������������������������� 
	If ExistDir(AllTrim(cDirFiles)) 
		aArquivos := Directory(cDirFiles+"*.txt")
		//Se n�o houver arquivos TXT na pasta n�o roda o ImpSPEDFis
		If Len(aArquivos)==0
			llProcess := .F.
		Else
			//�������������������������������������������������������������Ŀ
			//� Verifica se as tabelas do ImpSped est�o preenchidas         �
			//���������������������������������������������������������������
			alArea 		:= GetArea()      
			llProcess	:= .F.
			For nlCont:=1 to Len(alTabelas)
				If AliasIndic(alTabelas[nlCont]) 
	            	dbSelectArea(alTabelas[nlCont]) 
					If (nlQtdReg := &(alTabelas[nlCont])->(LastRec()))==0
						llProcess := !llProcess
						Exit 			       
					EndIF
				EndIf 	
			Next nlCont 
			RestArea(alArea)        
		Endif		
		//����������������������������Ŀ
		//� Executa o ImpSped          �
		//������������������������������
		If llProcess
			olProcess := MsNewProcess():New( {|| ImpSPEDFis(.F.,.F.,"",.F.,olProcess) } ,"Preparando ambiente do SPED FISCAL...","",.T.)
			olProcess:Activate()
			//Arquivos TXT renomeados - Backup apos atualiza��o
			For nlCont:=1 to Len(aArquivos)
				cArqBkp := cDirFiles+Subs(aArquivos[nlCont,1],1,Len(aArquivos[nlCont,1])-1)+"_"			
				If File(cArqBkp)
					Ferase(cArqBkp)
				Endif			
				FReName(cDirFiles+aArquivos[nlCont,1],cArqBkp)				
			Next		
		EndIf
	Endif

	//Tabela Gen�rica SY cadastrada incorretamente para o Fiscal, � usada no CTB -> Ajustar nome para o CTB e excluir registros do Fiscal
	aAreaSX5:=SX5->(GetArea())
	SX5->(dbSetOrder(1))
	If SX5->(dbSeek(xFilial("SX5")+'00'+'SY'))
		If AllTrim(SX5->X5_DESCRI)=='Codigo da Cor- DENATRAN'
			RecLock("SX5",.F.)
			SX5->X5_DESCRI :='Moedas Contabeis Bloco W ECF'
			SX5->X5_DESCSPA:='Monedas contables Bloque W ECF'
			SX5->X5_DESCENG:='W ECF Block Acc Currencies'
			MsUnLock()
		EndIf

		If SX5->(dbSeek(xFilial("SX5")+"SY"+"01"))
			Do while SX5->X5_FILIAL+SX5->X5_TABELA==xFilial("SX5")+"SY"
				If AllTrim(SX5->X5_CHAVE) $ "01/02/03/04/05/06/07/08/09/10/11/12/13/14/15/16"
					RecLock("SX5",.F.)
					SX5->(dbDelete())
					MsUnLock()
				EndIf
				SX5->(dbSkip())
			Enddo
		EndIf
	EndIf
	RestArea(aAreaSX5)
	
	//Mensagem do TAF
	//if !( file( cDirProf + "msg_taf_" + __cUserID + "-" + dToS( Date() ) + ".lck" ) )
		//FisLoadBanner()
		//If File(cDirProf + "msg_taf_" + __cUserID + "-" + dToS( Date()-1 ) + ".lck")
		//	fErase( cDirProf + "msg_taf_" + __cUserID + "-" + dToS( Date()-1 ) + ".lck" )
		//EndIf
		//nHdl := fCreate( cDirProf + "msg_taf_" + __cUserID + "-" + dToS( Date() ) + ".lck" )
		//if nHdl < 0
		//	conout("Erro ao criar arquivo de lock - msg_taf: " + str( fError() ) )
		//endif
	//endif
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FISBannerTAF

Funcao responsabel em existir a mensagem de obrigatoriedade de uso do TAF para gerar as obriga��es fiscais a partir de uma determinada data.
Ela utiliza um jpg desenvolvido por MKT ( banner_taf.jpg ).
Se existir compilado o resource de Banner (.jpg) no reposit�rio, ele utiliza uma apresentacao mais elaborada. Pode acontecer do programa 
n�o estar no RPO, por isso faz um tratamento com getResArray.

@param Nil

@return Nil

@author Gustavo G. Rueda
@since 09/09/2016
/*/
//-------------------------------------------------------------------
Function FISBannerTAF()
Local	nLin	as	numeric
Local	ncol	as	numeric
Local	oDlg	as	object
Local	oLayer	as	object
Local	oSay	as	object
Local	bClick	as	codeblock
Local	oFont 	as	object
Local	cImg	as	char
Local	cTxt	as	char
Local	aRes	as	array

cImg			:=	'banner_taf'
aRes			:=	getResArray( cImg + '.jpg' )
cTxt			:=	''
oFont 			:= 	TFont():New('Arial',,-12,.T.)
oLayer 			:= 	FWLayer():New()
bClick			:=	{|| ShellExecute("open","http://tdn.totvs.com.br/pages/viewpage.action?pageId=268587913","","",1)}
nLin			:=	0
nCol			:=	820

If !( len( aRes ) > 0 )
	cTxt	:=	'<b>Prezado cliente,</b><br><br>'+ CRLF + CRLF
	cTxt	+=	'Sabemos que o cotidiano do profissional da �rea de tributos � bastante din�mico e exige um controle detalhado de todas as atividades que envolvem obriga��es fiscais.<br><br>'
	cTxt	+=	'Pensando nisso, a TOTVS desenvolveu o <b>TAF - TOTVS Automa��o Fiscal</b>, que � uma solu��o especialista em consolida��o de informa��es e converg�ncia fiscal.<br><br>'
	cTxt	+=	'Ao utilizar essa solu��o, voc� ganha <b>desempenho</b> na gera��o de obriga��es fiscais, <b>velocidade na implementa��o, suporte t�cnico personalizado e consultoria tribut�ria.</b><br><br>'
	cTxt	+=	'A partir de Fevereiro de 2017, algumas obriga��es fiscais na linha Microsiga Protheus passar�o a ser atendidas somente atrav�s do TAF.<br><br>'
EndIf

if !Empty( cTxt ) //quando o resoruce ( banner ) n�o estiver no rpo
	nLin	:=	470
else
	//foi necess�rio aumentar a tela de 520 para 570 e 420 para 470 devido a um problema de lib onde o bot�o (X) que fecha a tela
	//n�o est� aparecendo na vers�o 12. Ajustar ap�s corre��o do fw.
	nLin	:=	570
endif

//foi necess�rio comentar o "nOr( WS_VISIBLE, WS_POPUP )" devido a um problema de lib onde o bot�o (X) que fecha a tela do objeto FWLayer
//n�o est� aparecendo na vers�o 12. Descomentar ap�s corre��o do fw.
oDlg := MsDialog():New( 0, 0, nLin, nCol, "",,,, /*nOr( WS_VISIBLE, WS_POPUP )*/,,,,, .T.,,,, .F. )
oLayer:Init( oDlg, .T. )
oLayer:AddLine( "LINE01", 100 )
oLayer:AddCollumn( "BOX01", 100,, "LINE01" )
oLayer:AddWindow( "BOX01", "PANEL01", 'IMPORTANTE...', 100, .F.,,, "LINE01" )

If !Empty( cTxt )
	oSay	:=	TSay():New(10,10,{|| cTxt },oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ),,oFont,,,,.T.,,,380,nLin,,,,,,.T.)
	oSay:lWordWrap = .T.
	TButton():New( 155, 335, "SAIBA MAIS",oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ), bClick, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
Else
	TBitmap():New(0,0,nLin,nCol,cImg,,.T.,oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ),bClick,bClick,,.F.,,,,,.T.)
EndIf

oDlg:Activate(,,,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisChkBan
 
Fun��o que ir� fazer verifica��o se deve ou n�o exibir o banner para usu�rio
Basicamente ir� verificar se � a primeira vez que o usu�rio logou no SIGAFIS
Se for ent�o o banner ser� exibido, caso contr�rio o banner n�o ser� exibido
Assim n�o ir� exibir todas as vezes que entrar no SIGAFIS, sendo uma
esp�cie de p�lupa di�ria

cUser - C�digo do usu�rio 
cRotina - Nome da rotina
cTask - Nome da tarefa
cMemo - Conte�do a ser gravado no profile do usu�rio

@author Erick G. Dias
@since 06/09/2017


/*/
//-------------------------------------------------------------------
Static Function FisChkBan(cUser, cRotina, cTask, cMemo)

Local lRet			:= .F.
Local oFwProfile	:= Nil
Local cRetFw	:= ''

//Cria objeto FWPROFILE
oFwProfile	:= FWPROFILE():New()

//Passa usu�rio
oFwProfile:SetUser(cUser)
//passa rotina
oFwProfile:SetProgram(cRotina)
//passa task
oFwProfile:SetTask(cTask)

//Realiza load para verificar a �ltima informa�� gravada no profile do usu�rio
oFwProfile:Load()
cRetFw := oFwProfile:GetStringProfile()

//Verifica se o conte�do gravado � diferente do que est� sendo enviado para esta fun��o
IF alltrim(cRetFw) <> alltrim(cMemo)
	
	//Se sim ent�o � a primeira vez que o usu�rio est� logando, dever� exbiri o banner e gravar novo conte�do no profile do usu�rio	
	lRet	:= .T.
	oFwProfile:SetStringProfile(cMemo)
	oFwProfile:Save()
	
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisLoadBan
 
Fun��o que ir� exibir o banner conforme URL passada

cUrl - URL da p�gina 

@author Erick G. Dias
@since 06/09/2017

/*/
//-------------------------------------------------------------------

Static Function FisLoadBan(cUrl, cTitle)

Local oDlg 			:= Nil
Local oTIBrowser	:= Nil
Local oPanel		:= nil
Local aSize 	    := MsAdvSize()
 
oDlg := FWDialogModal():New()
oDlg:SetBackground(.F.)  
oDlg:SetTitle(cTitle)
oDlg:SetEscClose(.T.)
oDlg:SetSize(aSize[4] * 0.8,aSize[3] * 0.8) 
oDlg:EnableFormBar(.T.)

oDlg:CreateDialog() 
oDlg:createFormBar()
oDlg:addCloseButton()	
oPanel := oDlg:getPanelMain()   

oTIBrowser := TIBrowser():New(0,0,aSize[3] *0.8,aSize[4] *0.8,cUrl,oPanel)
oTIBrowser:GoHome()                   

oDlg:Activate()

Return
