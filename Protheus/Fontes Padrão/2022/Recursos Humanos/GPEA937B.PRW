#include 'PROTHEUS.CH'
#include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#Include 'GPEA937B.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Env2200
Rotina que gera o evento 2200 na troca de cpf
@author  gisele nuncherino
@since   03/09/19
@version V01
/*/
//-------------------------------------------------------------------
Function Gera2200()

Local cStat2200     := ''
Local cStat2300		:= ""
Local lProc			:= .F.
Local aLog			:= {}
Local aRet			:= {}
Local cAntigoCPF    := RJI->RJI_CPFA
Local cNovoCodUnic  := ''
Local cTrabVincu    := fCatTrabEFD("TCV")
Local cVersEnvio    := ''
Local cVersGPE      := ''
Local nRecRJI		:= RJI->(recno())

If RJI->RJI_STATUS == '0' 
    MsgAlert(OemtoAnsi(STR0002), OemtoAnsi(STR0001))
    Return
EndIf

//RJI_CPFA+RJI_FILIAL+RJI_MAT+RJI_STATUS
RJI->(DBSETORDER(3))
RJI->(DBGOTOP())
RJI->(DBSEEK(cAntigoCPF))

Begin Transaction 

    //Gerar novamente o RA_CODUNIC e alterar o SRA (da matricula principal e dos demais vínculos)
    aAdd(aLog, OemtoAnsi(STR0003))
    aadd(alog, OemtoAnsi(STR0010))
    aAdd(aLog, '________________________________________________________________')
 
    WHILE !RJI->(EOF()) .AND. RJI->RJI_CPFA == cAntigoCPF

        //RA_FILIAL+RA_CIC
        SRA->(DBSETORDER(5))
        IF RJI->RJI_STATUS == '2'
            IF SRA->(DBSEEK(RJI->RJI_FILIAL + RJI->RJI_CPF))
                regtomemory("SRA")
            ENDIF
        ELSE
            IF SRA->(DBSEEK(RJI->RJI_FILIAL + RJI->RJI_CPFA))
                regtomemory("SRA")
            ENDIF
        ENDIF        

        // TRABALHADOR COM VINCULO
        If SRA->RA_CATEFD $ cTrabVincu       
	        If FindFunction("fVersEsoc")
	            fVersEsoc("S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE )
	        EndIf
	
	        IF RJI->RJI_STATUS <> '2'
	            cNovoCodUnic    := fRACodUnic()
	        ELSE
	            cNovoCodUnic    := SRA->RA_CODUNIC
	        ENDIF        
	        
	        cStat2200	    := TAFGetStat( "S-2200", AllTrim(RJI->RJI_CPF) + ";" + ALLTRIM(cNovoCodUnic), , RJI->RJI_FILIAL )
	
	        //Se encontrou o S-2200 com status 4 
	        //significa que já foi enviado o S-2200
	        //sendo assim, apresentar a pergunta: "Evento S-2200 já existe, deseja gerar retificador?"
	        IF cStat2200 == '4'
	            IF MsgYesNo(OemtoAnsi(STR0004) , OemtoAnsi(STR0001) )
	                // RETIFICACAO DO EVENTO S-2200
	                lProc := fIntAdmiss("SRA",,0,"S2200",RJI->RJI_FILIAL,,cNovoCodUnic, ,"ADM",@aRet,cVersEnvio, , , , , , , , , , , , , , , , , , , , .T., cNovoCodUnic)
	            ELSE
	                MsgAlert(OemtoAnsi(STR0011), OemtoAnsi(STR0001))
					DisarmTransaction() 
	                RETURN
	            ENDIF 
	        ELSE
	            // GERAR S-2200
	            lProc := fIntAdmiss("SRA",,0,"S2200",RJI->RJI_FILIAL,,cNovoCodUnic, ,"ADM",@aRet,cVersEnvio, , , , , , , , , , , , , , , , , , , , .T., cNovoCodUnic)
	        ENDIF
	    Else
	    	// TRABALHADOR SEM VINCULO
		    If FindFunction("fVersEsoc")
		        fVersEsoc("S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE)
		    EndIf
		
		    If RJI->RJI_STATUS <> '2'
		        cNovoCodUnic := fRACodUnic()
		    Else
		        cNovoCodUnic := SRA->RA_CODUNIC
		    EndIf        
		    
		    cStat2300 := TAFGetStat("S-2300", AllTrim(RJI->RJI_CPF) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS(SRA->RA_ADMISSA))
		
		    // SE ENCONTROU O S-2300 COM STATUS 4 
		    // SIGNIFICA QUE JÁ FOI ENVIADO O S-2300
		    // SENDO ASSIM, APRESENTAR A PERGUNTA: "EVENTO S-2300 JÁ EXISTE, DESEJA GERAR RETIFICADOR?"
		    If cStat2300 == '4'
		        If MsgYesNo(OemtoAnsi(STR0012), OemtoAnsi(STR0001))
		            // RETIFICACAO DO EVENTO S-2300
					lProc := fInt2300New("SRA",, 0, "S2300", RJI->RJI_FILIAL,, cVersEnvio,,,,,,, .T.)
		        Else
		            MsgAlert(OemtoAnsi(STR0014), OemtoAnsi(STR0001))
					DisarmTransaction() 
		            Return
		        EndIf 
		    Else
		        // GERAR S-2300
				lProc := fInt2300New("SRA",, 3, "S2300", RJI->RJI_FILIAL,, cVersEnvio,,,,,,, .T.)
		    EndIf
	    EndIf
	    
        aAdd(aLog, CRLF)
        aAdd(aLog, oemtoAnsi(STR0005) + alltrim(SRA->RA_FILIAL) + oemtoAnsi(STR0006) + alltrim(SRA->RA_MAT) + oemtoAnsi(STR0007) +  SRA->RA_CIC + '    => ' + iif(lproc,oemtoAnsi(STR0008) , oemtoAnsi(STR0009) + CRLF + ARET[1]))

        if lProc
            //Após gerar o evento S-2200 é necessário atualizar o campo RJI_STATUS, com o conteúdo igual a "2" e os dados da SRA
            RECLOCK("RJI", .F.)
                RJI->RJI_STATUS := "2"
            RJI->(MSUNLOCK())

            RECLOCK("SRA", .F.)
               SRA->RA_CODUNIC  := cNovoCodUnic
               SRA->RA_CIC      := RJI->RJI_CPF
            SRA->(MSUNLOCK())
        ELSE    
            EXIT
        ENDIF
        RJI->(DBSKIP())
    ENDDO
    
    if !lProc
        DisarmTransaction()
        ShowLog(STR0001,aLog)
    ELSE    
        fEFDMsg()
    Endif

End Transaction

RJI->(DBGOTOP())
RJI->(DBGOTO(nRecRJI))

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} function ShowLog
Rotina que gera o log do processamento
@author  gisele nuncherino
@since   03/09/19
@version V01
/*/
//-------------------------------------------------------------------
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