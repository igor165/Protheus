#include 'totvs.ch'
#include 'plsjntme.ch'
#Include "MsOle.ch"
#include "fileio.ch"

/*/{Protheus.doc} PLSJNTME
Classe com as Rotinas utilizadas para o processo de junta m�dica

@author Roberto Vanderlei
@since 30/07/2015
@version P12
/*/
CLASS PLSJNTME

	METHOD New() CONSTRUCTOR

ENDCLASS

METHOD New() CLASS PLSJNTME

Return
//-----------------------------------------------------------------


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSUPJNT� Autor � Roberto Vanderlei      � Data � 30.07.15 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualiza B53 Junta M�dica				  				  		 ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/               
Function PLSUPJNT()

	local lRetorno := .T.
	
	If (B53->B53_ROTGEN == "1")
		Alert (STR0010) //"Op��o n�o dispon�vel para Rotina Gen�rica"
		Return
	EndIf
	
	if MsgYesNo(IIF(B53->B53_JNTMED <> "1", STR0001, STR0002) , STR0003) //Deseja iniciar o processo de junta m�dica ? - Deseja finalizar o processo de junta m�dica ?
	
		B53->(RecLock("B53",.F.))
		B53->B53_JNTMED :=  IIF(B53->B53_JNTMED <> "1", "1", "0")
		B53->(MsUnLock())
		
	endif
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �PLSJNTANX� Autor � Roberto Vanderlei      � Data � 30.07.15 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Abre a tela correpondente ao tipo de anexo. 		  		  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/               
Function PLSJNTANX(cTipoAnexo)

	Local aPergs:= {}
	Local cTitulo  := "Gerar"
	Local aRet     := {}  
	local cNumOcor := 458
	local cRecDest := ""
	
	local cEmail
	local cCodPro
	local cCodPad
	local cProcedimento
	local cMunici
	local cEmailAdicional := space(1000)
	
	STATIC o790C := PLSA790C():New()
	
	DbSelectArea("BA1")
	BA1->( dbSetorder(2) )
	BA1->( dbSeek(xFilial("BA1")+B53->B53_MATUSU) )
	
	DbSelectArea("BTS")
	BTS->( dbSetorder(1) )
	BTS->( dbSeek(xFilial("BTS")+BA1->BA1_MATVID) )

	DbSelectArea("BAU")
	BAU->( dbSetorder(1) )
	BAU->( dbSeek(xFilial("BAU")+B53->B53_CODRDA))
	
	cCodPad := (o790C:cAIte)->&(o790C:cAIte+"_CODPAD")
	cCodPro := (o790C:cAIte)->&(o790C:cAIte+"_CODPRO")	
		
	cProcedimento := Posicione("BR8",1,xFilial("BR8")+cCodPad+cCodPro,"BR8_DESCRI")
	
	cEmail := iif(alltrim(BA1->BA1_EMAIL) = "", alltrim(BTS->BTS_EMAIL), alltrim(BA1->BA1_EMAIL))
		
	if cTipoAnexo = "1"
	
			//cTitulo  := "Gerar Anexo I - Benefici�rio"
		
		aAdd( aPergs ,{1,"Benefici�rio",BA1->BA1_NOMUSR,"@!",'',,'.T.',iif(len(alltrim(BA1->BA1_NOMUSR)) * 4 <120, 120, len(alltrim(BA1->BA1_NOMUSR)) * 4),.F.})
		aAdd( aPergs ,{1,"Endere�o",BA1->BA1_ENDERE,"@!",'',,'.T.',iif(len(alltrim(BA1->BA1_ENDERE)) * 4 = 0, 120, len(alltrim(BA1->BA1_ENDERE)) * 4) ,.F.})
		aAdd( aPergs ,{1,"N�mero",BA1->BA1_NR_END,"@!",'',,'.T.',40,.F.})
		aAdd( aPergs ,{1,"Bairro",BA1->BA1_BAIRRO,"@!",'',,'.T.', iif(len(alltrim(BA1->BA1_BAIRRO)) * 4 = 0, 100, len(alltrim(BA1->BA1_BAIRRO)) * 4) ,.F.})
		aAdd( aPergs ,{1,"CEP",BA1->BA1_CEPUSR,"@@@@@@@@",'',,'.T.', 40 ,.F.})
		aAdd( aPergs ,{1,"Munic�pio",BA1->BA1_MUNICI,"@!",'',,'.T.', iif(len(alltrim(BA1->BA1_MUNICI)) * 4 = 0, 100, len(alltrim(BA1->BA1_MUNICI)) * 4) ,.F.})
						
		aAdd( aPergs ,{1,"Procedimento",cProcedimento,"@!",'',,'.T.',iif(len(alltrim(cProcedimento)) * 4 < 120, 120, len(alltrim(cProcedimento)) * 4),.F.})//15
		
		aAdd( aPergs ,{1,"E-mail do Benefici�rio",cEmail + SPACE(80),"@!",'',,'.T.',/*120*/iif(len(alltrim(cEmail)) * 4 < 120, 120, len(alltrim(cEmail)) * 4) ,.F.}) 
	else
		if cTipoAnexo = "2"
			//cTitulo  := "Gerar Anexo II - M�dico Assistente"
					
			aAdd( aPergs ,{1,"Benefici�rio",alltrim(BA1->BA1_NOMUSR),"@!",'',,'.T.',iif(len(alltrim(BA1->BA1_NOMUSR)) * 4 <120, 120, len(alltrim(BA1->BA1_NOMUSR)) * 4),.F.})
			aAdd( aPergs ,{1,"Prestador",alltrim(BAU->BAU_NOME),"@!",'',,'.T.',iif(len(alltrim(BAU->BAU_NOME)) * 4 < 120, 120, len(alltrim(BAU->BAU_NOME)) * 4),.F.})
			aAdd( aPergs ,{1,"Endere�o Prestador",alltrim(BAU->BAU_END),"@!",'',,'.T.',iif(len(alltrim(BAU->BAU_END)) * 4 < 120, 120, len(alltrim(BAU->BAU_END)) * 4),.F.})
			aAdd( aPergs ,{1,"N�mero do end. do Prestador",alltrim(BAU->BAU_NUMERO),"@!",'',,'.T.',40,.F.})
			aAdd( aPergs ,{1,"Bairro do Prestador",alltrim(BAU->BAU_BAIRRO),"@!",'',,'.T.',iif(len(alltrim(BAU->BAU_END)) * 4 < 100, 100, len(alltrim(BAU->BAU_END)) * 4),.F.})
			
			aAdd( aPergs ,{1,"CEP",BAU->BAU_CEP,"@@@@@@@@",'',,'.T.', 40 ,.F.})
			
			cMunici  := Posicione("BID",1,xFilial("BID")+BAU->BAU_MUN,"BID_DESCRI")
			
			aAdd( aPergs ,{1,"Munic�pio do Prestador",alltrim(cMunici),"@!",'',,'.T.',iif(len(alltrim(cMunici)) * 4 < 100, 100, len(alltrim(cMunici)) * 4),.F.})
					
			aAdd( aPergs ,{1,"Procedimento",cProcedimento,"@!",'',,'.T.',iif(len(alltrim(cProcedimento)) * 4 < 120, 120, len(alltrim(cProcedimento)) * 4),.F.})
			aAdd( aPergs ,{1,"E-mail do Prestador",alltrim(BAU->BAU_EMAIL) + SPACE(80),"@!",'',,'.T.',iif(len(alltrim(BAU->BAU_EMAIL)) * 4 <120, 120, len(alltrim(BAU->BAU_EMAIL)) * 4),.F.}) 		
		else
			if cTipoAnexo = "3"
				//cTitulo  := "Gerar Anexo III - Convoca��o"
														
				aAdd( aPergs ,{1,"Prestador:",space(1000),"@!",'',,'.T.',120,.F.})
				
				aAdd( aPergs ,{1,"Procedimento:",cProcedimento,"@!",'',,'.T.',iif(len(alltrim(cProcedimento)) * 4 < 120, 120, len(alltrim(cProcedimento)) * 4),.F.})
				aAdd( aPergs ,{1,"Dt. Convoca��o",space(10),"99/99/9999",'',,'.T.',35,.F.})
				aAdd( aPergs ,{1,"Hor�rio:",space(5),"99:99",'',,'.T.',10,.F.})
						
				aAdd( aPergs ,{1,"E-mail do Prestador",alltrim(BAU->BAU_EMAIL) + SPACE(80),"@!",'',,'.T.',iif(len(alltrim(BAU->BAU_EMAIL)) * 4 <120, 120, len(alltrim(BAU->BAU_EMAIL)) * 4),.F.}) 
				aAdd( aPergs ,{1,"E-mail do Benefici�rio",cEmail + SPACE(80),"@!",'',,'.T.',/*120*/iif(len(alltrim(cEmail)) * 4 < 120, 120, len(alltrim(cEmail)) * 4) ,.F.}) 
				
				aAdd( aPergs ,{1,"E-mail's (separar por ';')", cEmailAdicional + SPACE(100) ,"@!","MAILVAL('3')",,'.T.',120,.F.}) 
				
			else
				//cTitulo  := "Gerar Anexo IV - Ata"

				aAdd( aPergs ,{1,"Data",space(10),"99/99/9999",'',,'.T.',35,.F.})
				aAdd( aPergs ,{1,"Hor�rio:",space(5),"99:99",'',,'.T.',10,.F.})
				
				aAdd( aPergs ,{1,"Prestadores",space(1000),"@!",'',,'.T.',120,.F.})
						
				aAdd( aPergs ,{1,"Procedimento",cProcedimento,"@!",'',,'.T.',iif(len(alltrim(cProcedimento)) * 4 < 120, 120, len(alltrim(cProcedimento)) * 4),.F.})
				
				aAdd( aPergs ,{1,"Benefici�rio",BA1->BA1_NOMUSR,"@!",'',,'.T.',iif(len(alltrim(BA1->BA1_NOMUSR)) * 4 <120, 120, len(alltrim(BA1->BA1_NOMUSR)) * 4),.F.})
								
				aAdd( aPergs ,{1,"M�dicos Indicados",space(1000),"@!",'',,'.T.',120,.F.})

				aAdd( aPergs ,{1,"E-mail do Prestador",alltrim(BAU->BAU_EMAIL)  + SPACE(80),"@!",'',,'.T.',iif(len(alltrim(BAU->BAU_EMAIL)) * 4 <120, 120, len(alltrim(BAU->BAU_EMAIL)) * 4),.F.}) 
				aAdd( aPergs ,{1,"E-mail do Benefici�rio",cEmail + SPACE(80),"@!",'',,'.T.',/*120*/iif(len(alltrim(cEmail)) * 4 < 120, 120, len(alltrim(cEmail)) * 4) ,.F.}) 
				
				aAdd( aPergs ,{1,"E-mail's (separar por ';')", cEmailAdicional + SPACE(80) ,"@!","MAILVAL('4')",,'.T.',120,.F.}) 
				
				//Adicionar Grade para inclus�o de e-mails opcionais							
			endif
		endif
	endif
	
	If ParamBox(aPergs ,cTitulo,@aRet,,,.T.,256,129,,,.F.,.F.) 
		GERAANX(cTipoAnexo, aRet)
	endif 	
Return 


Function MAILVAL(cTipoAnexo)
	local aArroba
	local aPonto
	
	aArroba := STRTOKARR(iif(cTipoAnexo = "3", MV_PAR07, MV_PAR09) ,"@") 
	aPonto  := STRTOKARR(iif(cTipoAnexo = "3", MV_PAR07, MV_PAR09),";")
	
	if len(aArroba) > len(aPonto) + 1  	
		MsgAlert(STR0007)
	endif
return


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    �GERAANX� Autor � Roberto Vanderlei      � Data � 30.07.15   ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Gera as cartas de acordo com o tipo. 		  		  			 ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/               
Static Function GERAANX(cTipoAnexo, aResultado)

	local aCampoValor := {}
	local cSequen
	local cNumGui
	local cAliasIte
	local lRet
	local lCopy
	local cDirLocal := GetNewPar( "MV_CTRJNM" , "" )
	local cDirModelo   := GetNewPar( "MV_MODJNTM" , "" )
	local cExtens
	local cRet
	local cEndOperadora
	local cEmailEnviar := ""
	local cEmailCCO := ""
	local aArqOri
	local nXi
	Local aMeses := {'janeiro','fevereiro','mar�o',;
               	   'abril' ,'maio','junho',;
               	   'julho' ,'agosto'   ,'setembro',;
               	   'outubro','novembro' ,'dezembro'} 
	private oWord
	private cDirTemp := ""
	private cTempPath := ""
	private cNomeArquivo := ""
	STATIC o790C := PLSA790C():New()
	
	cAliasIte := o790C:cAIte
	cNumGui := B53->B53_NUMGUI
	cSequen := (o790C:cAIte)->&(o790C:cAIte+"_SEQUEN")
	
	if MsgYesNo(IIF(cTipoAnexo = "1", STR0004, iif(cTipoAnexo = "2", STR0005, STR0006)) , STR0003) //Deseja realmente gerar a carta e enviar e-mail para o Benefici�rio ? / Deseja realmente gerar a carta e enviar e-mail para o Prestador ? / Deseja realmente gerar a carta e enviar e-mail para o Prestador e Benefici�rio ?
		if cTipoAnexo = "1"
	
			// 1- Nome Benefici�rio
			// 2- Endereco
			// 3- Numero
			// 4- Bairro
			// 5- CEP
			// 6- Cidade
			// 7- Procedimento
			// 8- Email
			aadd(aCampoValor, {"NOMEBENEF",    CAPITAL(aResultado[1])})
			aadd(aCampoValor, {"RUABENEF",     CAPITAL(aResultado[2])})
			aadd(aCampoValor, {"NUMBENEF",     aResultado[3]})
			aadd(aCampoValor, {"BAIRROBENEF",  CAPITAL(aResultado[4])})
			aadd(aCampoValor, {"CEPBENEF",     aResultado[5]})
			aadd(aCampoValor, {"CIDADEBENEF",  CAPITAL(aResultado[6])})
			aadd(aCampoValor, {"PROCEDIMENTO", CAPITAL(aResultado[7])})
			aadd(aCampoValor, {"EMAILBENEF",   aResultado[8]})
			aadd(aCampoValor, {"DTATUAL",   	DTOC(DATE())})
			aadd(aCampoValor, {"ANO",   	    STR(YEAR(DATE()))})		  
			
			cEmailEnviar := aResultado[8]
		else
	
		    if cTipoAnexo = "2"
		    
				// 1- Nome Benefici�rio
				// 2- Nome Prestador
				// 3- Rua 
				// 4- N�mero
				// 5- Bairro
				// 6- CEP
				// 7- Cidade
				// 8- Procedimento
				// 9- Email	    
		    
				aadd(aCampoValor, {"NOMEBENEF",    CAPITAL(aResultado[1])})
				aadd(aCampoValor, {"NOMEPREST",    CAPITAL(aResultado[2])})
				aadd(aCampoValor, {"RUAPREST",     CAPITAL(aResultado[3])})
				aadd(aCampoValor, {"NUMPREST",     aResultado[4]})
				aadd(aCampoValor, {"BAIRROPREST",  CAPITAL(aResultado[5])})
				aadd(aCampoValor, {"CEPPREST",     aResultado[6]})
				aadd(aCampoValor, {"CIDADEPREST",  CAPITAL(aResultado[7])})
				aadd(aCampoValor, {"PROCEDIMENTO", CAPITAL(aResultado[8])})
				aadd(aCampoValor, {"EMAILPREST",   aResultado[9]})
				aadd(aCampoValor, {"DTATUAL",   	DTOC(DATE())})
				aadd(aCampoValor, {"ANO",   	    STR(YEAR(DATE()))})	  
				
				cEmailEnviar :=  aResultado[9]
			 else 
			 	 if cTipoAnexo = "3"
			 	 
			 	 		BA0->(DbSetOrder(1))
						BA0->(DbSeek(xFilial("BA0")+ PLSINTPAD()) )
						
						cEndOperadora := CAPITAL(alltrim(BA0->BA0_END)) + ", N� " + alltrim(BA0->BA0_NUMEND) + ", " + CAPITAL(alltrim(BA0->BA0_CIDADE)) + " - " + alltrim(BA0->BA0_EST)
	
						// 1- Nome Prestador
						// 2- Procedimento
						// 3- Dt. Convoca��o
						// 4- Hor�rio
						// 5- Email do Prestador
						// 6- Email do Benefici�rio
						// 7- E'mails
		    
						aadd(aCampoValor, {"NOMEPREST",    CAPITAL(aResultado[1])})
						aadd(aCampoValor, {"PROCEDIMENTO", CAPITAL(aResultado[2])})
						aadd(aCampoValor, {"DTCONVOCACAO", aResultado[3]})
						aadd(aCampoValor, {"HRCONVOCACAO", aResultado[4]})
						aadd(aCampoValor, {"EMAILPREST",   aResultado[5]})
						aadd(aCampoValor, {"EMAILBENEF",   aResultado[6]})
						aadd(aCampoValor, {"EMAILMEDICOS", aResultado[7]})
						aadd(aCampoValor, {"DIA",   	    PADL(alltrim(STR(DAY(DATE()))), 2, '0')})
						aadd(aCampoValor, {"MES",   	    STR(MONTH(DATE()))})
						
						aadd(aCampoValor, {"MESEXT",   	    aMeses[MONTH(DATE())]})
						
						aadd(aCampoValor, {"ANO",   	    STR(YEAR(DATE()))})
						aadd(aCampoValor, {"ENDOPERADORA", cEndOperadora })	    
						
						cEmailEnviar := aResultado[6] + ";" + aResultado[5] 
						cEmailCCO    := aResultado[7]	 	 		
			 	 else
						// 1- Dt. Realiza��o 
						// 2- Hr. Realiza��o
						// 3- Nome dos prestadores
						// 4- Procedimento
						// 5- Nome Benefici�rio
						// 6- Medicos Indicados
						// 7- Email Prestador
						// 7- Email Benefici�rio
						// 7- Email m�dicos indicados
		    
						aadd(aCampoValor, {"DTREALIZ",     aResultado[1]})
						aadd(aCampoValor, {"HRREALIZ", 		aResultado[2]})
						aadd(aCampoValor, {"NOMEPREST",    CAPITAL(aResultado[3])})
						aadd(aCampoValor, {"PROCEDIMENTO", CAPITAL(aResultado[4])})
						aadd(aCampoValor, {"NOMEBENEF",    CAPITAL(aResultado[5])})
						aadd(aCampoValor, {"MEDICOSINDIC", CAPITAL(aResultado[6])})
						aadd(aCampoValor, {"EMAILPREST",   aResultado[7]})
						aadd(aCampoValor, {"EMAILBENEF",   aResultado[8]})
						aadd(aCampoValor, {"EMAILMEDICOS", aResultado[9]})
						
						if MONTH(CTOD(aResultado[1])) > 0
							aadd(aCampoValor, {"DIA",   	    PADL(alltrim(STR(DAY(CTOD(aResultado[1])))), 2, '0')})
							aadd(aCampoValor, {"MESEXT",   	    aMeses[MONTH(CTOD(aResultado[1]))]})
							aadd(aCampoValor, {"ANO",   	    STR(YEAR(CTOD(aResultado[1])))})
						endif
						
						aadd(aCampoValor, {"DIAATUAL",   	 PADL(alltrim(STR(DAY(DATE()))), 2, '0')})
						aadd(aCampoValor, {"MESEXTATUAL",   aMeses[MONTH(DATE())]})
						aadd(aCampoValor, {"ANOATUAL",   	 STR(YEAR(DATE()))})
						
						cEmailEnviar := aResultado[7] + ";" + aResultado[8] 
						cEmailCCO 	   := aResultado[9]
			 	 endif
			 endif 
		endif	
		
		GeraWord(cTipoAnexo, aCampoValor)
		
		//Adicionando na base de conhecimento		
		PLSINCONH(cDirTemp  + "\" + cNomeArquivo + ".doc", cAliasIte, xFilial(cAliasIte) + cNumGui + cSequen)
		
		//Salvando o arquivo localmente.
		lRet := MontaDir( cDirLocal ) //Cria o diret�rio se n�o existir
		
		if !lRet //Se n�o conseguiu criar, solicita o diret�rio em que dever� ser salvo.
			cExtens   := "Arquivo Texto ( *.* ) |*.*|"
			cRet := cGetFile( cExtens, STR0008/*"Selecione o Local para Salvar o Anexo"*/,,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
			cDirLocal := ALLTRIM( cRet )
		endif
		
		lCopy := CpyS2T(cDirModelo + "/" + cNomeArquivo + ".doc" , cDirLocal , .F. ) //Faz a copia dos arquivos do Servidor para o Remote

		PLSinaliza(nil,nil,nil, /*"roberto.arruda@totvs.com"*/cEmailEnviar, "Envio email de anexo - Junta medica",,,, cDirModelo + "/pdf/" + cNomeArquivo + ".pdf", "PLSANEXO", .T.,,,,alltrim(cEmailCCO))
				 //(cCodMail, cMsg, 1, cMailCan, "Solicita��o de altera��o contratual", oB5G, "B5G_ENVIOU", .T.)			
		if !lCopy 
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Problema na C�pia" , "Houve um problema com a c�pia do Anexo para a m�quina local. Dir: " + cDirLocal , 0, 0, {})
		else //Se conseguiu copiar, apaga do servidor.
			If File( cDirModelo + "/" + cNomeArquivo + ".doc" )
				FErase( cDirModelo + "/" + cNomeArquivo + ".doc" )
			EndIf

			If File( cTempPath + cNomeArquivo + ".doc" )
				FErase( cTempPath + cNomeArquivo + ".doc" )
			EndIf
			
			If File( cTempPath + cNomeArquivo + ".pdf" )
				FErase( cTempPath + cNomeArquivo + ".pdf" )
			EndIf						
			 
			//aEval(directory("\"+ STRTRAN(cDirModelo,"/", "\") + "\pdf\" + "*.pdf"), { |aFile| FERASE(aFile[F_NAME]) })
			
			MsgInfo(/*"Gera��o de anexo finalizada com sucesso."*/STR0009 + cDirLocal + cNomeArquivo + ".doc" , STR0003 + ".")
		endif
		
	endif

return

function ApagaPDF()

	local aArqOri
	local nXi
	local cDirModelo := GetNewPar( "MV_MODJNTM" , "" )
	  
	aArqOri := directory(STRTRAN(cDirModelo,"/", "\") + "\pdf\" + "*.pdf")
			
	for nXi := 1 to Len(aArqOri)
		FErase(cDirModelo + "/pdf/" + aArqOri[nXi, 1])
	next nXi
	
return


/*
���������������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��ͻ��
���Programa  � GeraWordAnexo �Autor � Roberto Vanderlei � Data � 03/08/2015   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Funcao que gera a pagina a ser impressa atraves do modelo.     ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � PLS                                                            ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
*/
Static Function GeraWord(cTipoAnexo, aResultado)
//Private cNomDp	:= ""

CriaNovo(cTipoAnexo)
ZeraCar(aResultado)
GravaCar(aResultado)
OLE_CloseFile(oWord)
OLE_CloseLink(oWord)

CpyT2S( cTempPath + cNomeArquivo + ".doc", cDirTemp)
CpyT2S( cTempPath + cNomeArquivo + ".pdf", cDirTemp + "\PDF")

Return()

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CriaNovo � Autor � Roberto Vanderlei � Data �03/08/2015    ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera o novo arquivo para gravacao.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/
Static Function CriaNovo(cTipoAnexo)
local cArqDot      := ""

local cDirModelo   := GetNewPar( "MV_MODJNTM" , "" )
cTempPath   := GetTempPath()

cDirTemp := ""

if SubStr(cDirModelo,1,1) <> "\"
	cDirTemp := "\"
endif

cDirTemp := cDirTemp + cDirModelo//GetSrvProfString("RootPath", "") + cDirModelo //+ "\"

if SubStr(cDirModelo,Len(cDirModelo),1) <> "\"
	cDirTemp := cDirTemp + "\"
endif

if SubStr(cDirModelo,1,1) <> "\"
	cDirModelo := "\" + cDirModelo
endif

cArqDot := iif(cTipoAnexo = "1", "AnexoI.dot", iif(cTipoAnexo = "2", "AnexoII.dot", iif(cTipoAnexo = "3", "AnexoIII.dot", "AnexoIV.dot")))

cNomeArquivo := SubStr(cArqDot,1,Len(cArqDot)-4) + DTOC(DATE()) + TIME() 

cNomeArquivo := strTran(cNomeArquivo, ":")
cNomeArquivo := strTran(cNomeArquivo, "/")

oWord := OLE_CreateLink()

__CopyFile( cDirTemp + cArqDot , cTempPath + cArqDot )	

//cDirTemp := cTempPath

//��������������������������������admin	�����������������������������������������ͻ
//�	Cria o novo arquivo no Remote											�
//�������������������������������������������������������������������������ͼ
OLE_NewFile( oWord , cTempPath /*+ "\"*/ + cArqDot )

//�������������������������������������������������������������������������ͻ
//�	Ajusta Propriedades do Arquivo											�admin	
//�������������������������������������������������������������������������ͼ
OLE_SetPropertie( oWord , oleWdVisible , .F. )

//�������������������������������������������������������������������������ͻ
//�	Salva o arquivo com o novo nome no Remote								�
//�������������������������������������������������������������������������ͼ

OLE_SaveAsFile( oWord , cTempPath + cNomeArquivo + ".doc" ,,, .F. , oleWdFormatDocument )

Return()

/* 
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ZeraCar  � Autor � Roberto Vanderlei  � Data � 03/08/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Zera os controladores para geracao de nova Carta.          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/
Static Function ZeraCar(aResultado)

local nFor 

for nFor := 1 to  len(aResultado) 
	OLE_SetDocumentVar(oWord	, aResultado[nFor][1] , "" )
next nFor

Return()

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GravaCar � Autor � Roberto Vanderlei  � Data � 06/08/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava dados do anexo.                							���
�������������������������������������������������������������������������͹��
���Uso       � PLS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/
Static Function GravaCar(aResultado)

	local nFor
	
	for nFor := 1 to len(aResultado)
		OLE_SetDocumentVar( oWord, aResultado[nFor][1] , AllTrim(aResultado[nFor][2]))
	next nFor
	
	OLE_SetDocumentVar(oWord , 'nomeArquivo' , cNomeArquivo + ".pdf" )
	OLE_SetDocumentVar(oWord , 'pastaDocs' , cTempPath/*cDirTemp + "\pdf\"*/ )
	
	OLE_UpdateFields(oWord)
	
	OLE_SaveAsFile( oWord , cTempPath + cNomeArquivo + ".doc" ,,, .F. , oleWdFormatDocument )
	
	OLE_ExecuteMacro(oWord, "vartypepdf" )
	
Return()
 

