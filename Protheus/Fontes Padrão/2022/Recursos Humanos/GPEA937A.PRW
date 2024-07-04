#include 'PROTHEUS.CH'
#include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#Include 'GPEA937A.ch'

Static cNTSV		:= SuperGetMv("MV_NTSV",,"")

#define CRLF Chr(13)+Chr(10) 

/*/
{Protheus.doc} function Gera2299
Função que gera o evento S-2299/S-2399 na Troca de CPF
@author  gisele
@since   29/08/2019
@version 1.0
/*/

Function Gera2299()

LOCAL c2200 := ""
LOCAL l2299 := ""
LOCAL l2399 := ""

Local lProc     := .F.
Local cMsgRet   := ""
Local aLog      := {}

Local cAntigoCPF    := RJI->RJI_CPFA
Local dDataDesl     := RJI->RJI_DTEF - 1

Local nRecRJI   := RJI->(recno())

Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo


//RJI_CPFA+RJI_FILIAL+RJI_MAT+RJI_STATUS
RJI->(DBSETORDER(3))
RJI->(DBGOTOP())
RJI->(DBSEEK(cAntigoCPF))

Begin Transaction 

    aAdd(aLog, OemtoAnsi(STR0007))
    aadd(alog, OemtoAnsi(STR0008))
    aAdd(aLog, '________________________________________________________________')
 
    WHILE !RJI->(EOF()) .AND. RJI->RJI_CPFA == cAntigoCPF

        // Se o status já estiver como 2 - "O evento S-2200 já foi gerado" não efetivar a operação
        IF RJI->RJI_STATUS == "2"
            MsgAlert( OemtoAnsi(STR0002) , OemtoAnsi(STR0001) ) 
            DisarmTransaction()
            return
        ENDIF

        //Se encontrou o S-2200 e S-2299 com status 4 
        //significa que já foi enviado o S-2299
        //sendo assim, apresentar a pergunta: "Evento S-2299 já existe, deseja gerar retificador?"

        //RA_FILIAL+RA_MAT
        DbSelectArea("SRA")
        SRA->(DbSetOrder(1))
        SRA->(DBSEEK(RJI->RJI_FILIAL + RJI->RJI_MAT))
        
        If SRA->RA_CATEFD $ cTrabVincu .or. Empty(SRA->RA_CATEFD)     // trabalhador com vinculo ou em branco       
	        c2200  := TAFGetStat( "S-2200", AllTrim(RJI->RJI_CPFA) + ";" + ALLTRIM(SRA->RA_CODUNIC), , RJI->RJI_FILIAL)
	        c2299  := TAFGetStat( "S-2299", AllTrim(RJI->RJI_CPFA) + ";" + ALLTRIM(SRA->RA_CODUNIC), , RJI->RJI_FILIAL)
	
	        IF c2200 <> '4' //Se encontrou somente o registro S-2200 com status diferente de 4 gerar o log informando que o S-2200 ainda não foi enviado ao RET
	            MsgAlert( OemtoAnsi(STR0004) , OemtoAnsi(STR0001) ) 
	            DisarmTransaction()
	            return
			elseif c2200 == '4' .and. c2299 == '4'
	            IF MsgYesNo(OemtoAnsi(STR0003) , OemtoAnsi(STR0001) )
	                // RETIFICACAO DO EVENTO S-2299
	                lProc := Env2299(RJI->RJI_FILIAL, RJI->RJI_CPF, dDataDesl, .T., @cMsgRet)
	            ELSE
	                MsgAlert(OemtoAnsi(STR0006), OemtoAnsi(STR0001))
	                DisarmTransaction()
	                RETURN
	            ENDIF 
	        ELSEIF c2200 == '4' .and. c2299 <> '4'
	            // GERAR S-2299
	            lProc := Env2299(RJI->RJI_FILIAL, RJI->RJI_CPF, dDataDesl, .F., @cMsgRet)
	        ELSE //Se não encontrou nenhum dos registros NÃO é necessário gerar o S-2299
	            MsgAlert(OemtoAnsi(STR0005), OemtoAnsi(STR0001))
	            DisarmTransaction()
	            RETURN
	        ENDIF
	    Else
	        c2300  := TAFGetStat( "S-2300", AllTrim(RJI->RJI_CPFA) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS(SRA->RA_ADMISSA) )
	        
	        IF c2300 <> '4' //Se encontrou somente o registro S-2200 com status diferente de 4 gerar o log informando que o S-2200 ainda não foi enviado ao RET
	            MsgAlert( OemtoAnsi(STR0004) , OemtoAnsi(STR0001) ) 
	            DisarmTransaction()
	            Return
	        ElseIf c2300 == '4' 
	            // GERAR S-2399
	            lProc := Env2399(RJI->RJI_FILIAL, RJI->RJI_CPF, dDataDesl, .F., @cMsgRet)
	        Else //Se não encontrou nenhum dos registros NÃO é necessário gerar o S-2399
	            MsgAlert(OemtoAnsi(STR0005), OemtoAnsi(STR0001))
	            DisarmTransaction()
	            Return
	        Endif
	   Endif
       aAdd(aLog, CRLF)
       aAdd(aLog, oemtoAnsi(STR0009) + alltrim(SRA->RA_FILIAL) + oemtoAnsi(STR0010) + alltrim(SRA->RA_MAT) + oemtoAnsi(STR0011) +  SRA->RA_CIC + '    => ' + iif(lproc,oemtoAnsi(STR0012) , oemtoAnsi(STR0013) + CRLF + cMsgRet))
	
       If lProc
           //Após gerar o evento S-2299 é necessário atualizar o campo RJI_STATUS, com o conteúdo igual a "1"
           RECLOCK("RJI", .F.)
               RJI->RJI_STATUS := "1"
           RJI->(MSUNLOCK())
       Else    
            Exit
       Endif
        RJI->(DBSKIP())
    ENDDO
    
    if !lProc
        DisarmTransaction()
        ShowLog(STR0001,aLog)
    ELSE    
        fEFDMsg()
    Endif
    ShowLog(STR0001,aLog)

End Transaction

RJI->(DBGOTOP())
RJI->(DBGOTO(nRecRJI))

Return


Function Env2299(cFilEnv, cNovoCPF, dDataDesl, lRetifica, cMsgRet)

	Local aArea 		:= GetArea()
	Local lGravou		:= .T.
	Local cTafKey    	:= ""
    Local cTpInsc		:= If( Len(cNovoCPF) == 11, "2", "1" )
	Local cVersEnvio 	:= '2.2'
    Local cVersGPE      := ''
	LOCAL cTrabVincu    := fCatTrabEFD("TCV")
    Local cIdDmDev      := ""
    Local nContRes		:= 0

	Default cNovoCPF	:= ""
	
	If FindFunction("fVersEsoc")
	    fVersEsoc( "S2299", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE )
	EndIf

	//-------------------
	//| Inicio do XML
	//-------------------
	cXml :=	'<eSocial>'
	cXml += 	'<evtDeslig>'

	//Dados do Trabalhador
	cXml +=			'<ideVinculo>'
	cXml +=				'<cpfTrab>' + AllTrim(SRA->RA_CIC) + '</cpfTrab>'
	cXml +=				'<nisTrab>' + AllTrim(SRA->RA_PIS) + '</nisTrab>'
	cXml +=				'<matricula>' + AllTrim(SRA->RA_CODUNIC) + '</matricula>'
	cXml +=			'</ideVinculo>'

    //Dados do Desligamento
	cXml += 		'<infoDeslig>'
	cXml += 			'<mtvDeslig>36</mtvDeslig>'
	cXml += 			'<dtDeslig>' + Dtos(dDataDesl) + '</dtDeslig>'
	cXml += 			'<indPagtoAPI>N</indPagtoAPI>'

    if lRetifica
		If cVersEnvio >= '2.3'
			cIdDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRG")) +  SRA->RA_MAT + If(lRetifica, "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
		EndIf    
	    cXml += "			<dmDev>"
	    cXml += "			<ideDmDev>" + cIdDmDev +  "</ideDmDev>"
        cXml += "			</dmDev>"
    Endif

	//Indicador de cumprimento de aviso prévio => 4 - Aviso prévio indenizado ou não exigível.
    cXml += 			'<indCumprParc>4</indCumprParc>'

	//Pensao Alimenticia => 0 - Não existe pensão alimentícia;
	cXml +=				'<pensAlim>0</pensAlim>'

    // mudanca de cpf
    cXml +=	 '<mudancaCPF>'
    cXml +=	    '<novoCPF>' + cNovoCPF + '</novoCPF>'
    cXml +=	 '</mudancaCPF>'

	//Fechamentos de Tags
	cXml += 		'</infoDeslig>'
	cXml +=		'</evtDeslig>'
	cXml +=	'</eSocial>'
	//-------------------
	//| Final do XML
	//-------------------

	GrvTxtArq(alltrim(cXml), "S2299", SRA->RA_CIC)

	cTafKey := "S2299" + AnoMes(dDataDesl) + SRA->RA_CIC + SRA->RA_CODUNIC
	aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2299", , "", , , , "GPE", , "" )

	If Len(aErros) > 0
		lGravou := .F.
		cMsgRet := aErros[1]
	Endif

	RestArea(aArea)

Return lGravou


Static Function ShowLog( cTitulo, aMemo )
	Local oDlg     := NIL
	Local oFont    := NIL
	Local oMemo    := NIL
	Local cMemo    := ""

	aEval( aMemo , { |X| cMemo += X + chr(13) + chr(10) } )
	
	DEFINE FONT oFont NAME "Courier New" SIZE 5,0
	DEFINE MSDIALOG oDlg TITLE cTitulo From 3,0 to 340,617 PIXEL

	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 300,145 READONLY OF oDlg PIXEL

	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,280 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL 
	ACTIVATE MSDIALOG oDlg CENTER
Return Nil

/*/
{Protheus.doc} function Env2399
Função Geração Evento de desligamento Func. s/ Vinc.
@author  staguti      
@since   03/10/2019
@version 1.0
/*/

Function Env2399(cFilEnv, cNovoCPF, dDataDesl, lRetifica, cMsgRet)

Local aArea 		:= GetArea()
Local lGravou		:= .T.
Local cTafKey    	:= ""
Local cTpInsc		:= If( Len(cNovoCPF) == 11, "2", "1" )
Local cVersEnvio 	:= '2.2'
Local cVersGPE      := ''
Local cIdDmDev      := ""
Local nContRes		:= 0
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"

Default cNovoCPF	:= ""
	
If FindFunction("fVersEsoc")
    fVersEsoc( "S2399", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE )	    
EndIf

	//-------------------
	//| Inicio do XML
	//-------------------
	
	cXml := "<eSocial>"
	cXml += "	<evtTSVTermino>"

	cXml += '		<ideTrabSemVinculo>'
	cXml += '			<cpfTrab>' + Alltrim( SRA->RA_CIC ) + '</cpfTrab>'
	If cVersEnvio < "9.0.00"
		cXml += '			<nisTrab>' + ALLTRIM( SRA->RA_PIS )	+ '</nisTrab>'
	ElseIf lGeraMat
		cXml += '			<matricula>' + ALLTRIM( SRA->RA_CODUNIC )	+ '</matricula>'
	EndIf
	cXml += '			<codCateg>' + AllTrim( SRA->RA_CATEFD ) + '</codCateg>'
	cXml += '		</ideTrabSemVinculo>'

	cXml += '		<infoTSVTermino>'
	cXml += '			<dtTerm>' + Dtos(dDataDesl) + '</dtTerm>'
	cXml += '			<mtvDeslig>07</mtvDeslig>'

    cXml +=	'			<mudancaCPF>'
    cXml +=	'				<novoCPF>' + cNovoCPF + '</novoCPF>'
    cXml +=	'			</mudancaCPF>'

	cXml += '		</infoTSVTermino>'
	cXml += '	</evtTSVTermino>'
	cXml += '</eSocial>'

	//-------------------
	//| Final do XML
	//-------------------

	GrvTxtArq(alltrim(cXml), "S2399", SRA->RA_CIC)

	cTafKey := "S2399" + AnoMes(dDataDesl) + SRA->RA_CIC + SRA->RA_CODUNIC
	aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2399", , "", , , , "GPE", , "" )

	If Len(aErros) > 0
		lGravou := .F.
		cMsgRet := aErros[1]
	Endif

	RestArea(aArea)

Return lGravou

	