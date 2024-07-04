#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#Include "TryException.ch"

#DEFINE oFBar      TFont():New( "Courier New"/*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFTitLabel TFont():New( "Courier New"/*cName*/, /*uPar2*/, -16/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFLabel    TFont():New( "Courier New"/*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfo     TFont():New( "Arial"      /*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .f./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFGrid     TFont():New( "Courier New"/*cName*/, /*uPar2*/, -10/*nHeight*/, /*uPar4*/, .f./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfoOBS  TFont():New( "Arial"      /*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFheader   TFont():New( "Arial"      /*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFontRecor TFont():New( "Tahoma"     /*cName*/, /*uPar2*/, -07/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )

#DEFINE CSSLABEL "QLabel {" +;
    "font-size:12px;" +;
    "font: 12px Arial;" +;
    "}"

/*----------------------------------------------------------------------------------,
 | Principal: 					     U_VACOMR10()          		                    |
 | Func:    VACOMR10 	            	          	            	                |
 | Autor:   Igor Gomes OLiveira           	            	          	            |
 | Data:    03/2023                   	          	            	                |
 | Ob:      Relatorio;                                                              |
 | Rotina:  MATA131 e MATA150;                                                      |
 | Desc:    Gera Relatorio de cotação para ser enviado aos fornecedores;            |
 '----------------------------------------------------------------------------------|
 | Alter:                                                                           |
 | Obs.:                                                                            |
'----------------------------------------------------------------------------------*/
User Function VACOMR10(aDados/* aCotacao,cTempo,aConteudo */)
    Private cTimeIni	    := Time()
    Private oPrinter        := nil
    Private aSolicit        := aCotacao
    //Private aDados       := {}
    Private cKey            := FWxFilial("SC8") + aSolicit[1] + aSolicit[2] + aSolicit[3]
    Private cArqName        := FWxFilial("SC8") + aSolicit[1] + aSolicit[2] + aSolicit[3] + "_" + StrTran(iif(PROCNAME(1) == 'U_MT131WF',aDados[1][23],cTimeIni),":","-",,)
    Private cServPath       := "\COTACOES\"
    Private cLocalPath      := "C:\TOTVS_RELATORIOS\COTACOES\"
    Private cMailFornece

    if PROCNAME(1) == 'U_MT131WF'
        if AllTrim(aDados[1][20]) == ""
            cMailFornece := Posicione("SA2",1,xFilial("SA2")+aDados[01][04]+aDados[01][21],"A2_EMAIL")
        else
            cMailFornece := aDados[1][20]
        endif
    ELSE
        cMailFornece := aDados[1][20]
    endif 

    if AllTrim(cMailFornece) == ''
        aDados := {}
        ShowHelpDlg("WFPROC01", {"O e-mail do fornecedor não está preenchido."}, 1, {"Por favor, preencha o e-mail do fornecedor e use a rotina de o reenvio da cotação em atualização de cotações."}, 1 )
        Return
    endif

    oPrinter := FWMSPrinter():New( cArqName, IMP_PDF/*nDevice*/ , .F./*lAdjustToLegacy*/, /*cPathInServer*/, .T./*lDisabeSetup*/,;
        /*lTReport*/, /*@oPrintSetup*/, /*cPrinter*/, /*lServer*/, .F./*lPDFAsPNG*/, /*lRaw*/,;
        .T. /*lViewPDF*/, /*nQtdCopy*/ )
    oPrinter:StartPage()
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize(DMPAPER_A4) // DMPAPER_A4 = A4 210 x 297 mm
    oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
    oPrinter:cPathPDF := cLocalPath // Caso seja utilizada impressão em IMP_PDF

    RptStatus({|lEnd| ImpTicket(@lEnd)}, "Imprimindo relatorio...") //"A imprimir relatório..."
    
    __CopyFile(cLocalPath+cArqName+".pdf", cServPath+cArqName+".pdf")

    if PROCNAME(1) != 'U_MT131WF'
        if Type("oMainWnd") == 'U' .or. Aviso("Email","Deseja Enviar email de cotação para o Fornecedor? ",{"Sim","Não"}) == 1
            SendMail()
        endif 
    endif 

   // SC8->(DBCloseArea())
Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ImpTicket 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  29.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function ImpTicket( lEnd )
    Private nRow        := 30, nColLabel:=30, nColInfo :=110
    Private cTxtAux     := ""
    Private cLogo       := "\system\lgrl" + AllTrim(cEmpAnt) + ".bmp"
    Private cReplc      := 65
    Private nTotLinOBS  := 4

    nTotLinha := (40/* linhas de textos */+3 /* linhas graficas de separacao */+nTotLinOBS/*linhas do campo de observacao*/)+2
    nTamLin   := /* 20 */ /* 19 */ 18.5
    
    oPrinter:Box( nRow*0.4, nBoxCol:=nColLabel*0.4, nBoxBottom:=(nTamLin*nTotLinha)*0.90, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
    fQuadro(1)

    oPrinter:EndPage()
    oPrinter:Preview()
    FreeObj(oPrinter)
    oPrinter := Nil

Return

Static Function fQuadro( nQuadro )
    Local nI        := 0 
    Local nCol2     := 180
    Local nGridLine
    Private nNumPag := 0 

    Default nQuadro := 0

    nBitMWidth:=150
    
    oPrinter:Say ( nRow         , nColLabel, PADC(AllTrim(SM0->M0_NOMECOM), cReplc*1.1 )/*cText>*/, oFTitLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )

    oPrinter:SayBitmap ( nRow+10/* -nColLabel *//*nRow*/, nColLabel/* -nColLabel *//*nCol*/, cLogo/*cBitmap*/, nBitMWidth, int(nBitMWidth/2)/*nHeight*/ )

    cTxtAux := AllTrim( SM0->M0_ENDENT )
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "Endereço.....:"/*cText>*/   , oFLabel/*oFont*/  , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux/*cText>*/            , oFInfo/*oFont*/   , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(SM0->M0_CEPENT, "@R 99999-999")) + ' ' + Alltrim(SM0->M0_CIDENT) + ' ' +  Alltrim(SM0->M0_ESTENT)
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "Município....:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux/*cText>*/            , oFInfo/*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    cTxtAux := Alltrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+' / '+Alltrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "CNPJ / IE....:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux/*cText>*/            , oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    cTxtAux := Alltrim(Transform(SubStr(StrTran(SM0->M0_TEL,'-',''),3), "@R (99) 9999-9999"))
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "Fone.........:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2 , cTxtAux/*cText>*/            , oFInfo/*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    PswOrder(1)
    PswSeek(__cUserId)
    cTxtAux := Iif(Empty(SY1->Y1_EMAIL), PswRet(1)[1][14], AllTrim(SY1->Y1_EMAIL))
    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2, "E-Mail.......:"/*cText>*/               ,oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo +nCol2, cTxtAux/*cText>*/   ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := AllTrim(Str(Year(dDataBase)) + ' / ' +  aDados[1][10] )
    oPrinter:Say ( nRow+=nTamLin, nColInfo + nCol2, "Processo de Compra:"/*cText>*/               ,oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + nColInfo + nCol2, cTxtAux/*cText>*/   ,oFInfoOBS /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Solicitamos proposta para fornecimento de materiais abaixo relacionados."/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Obs: Devolver sua proposta neste mesmo impresso."/*cText>*/,oFInfoOBS /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    //Dados do fornecedor 
    oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
    cTxtAux := aDados[1][4] + ' - ' + aDados[1][5]
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Fornecedor...:"/*cText>*/     ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo , cTxtAux /*cText>*/  ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    cTxtAux := aDados[1][12]
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Endereço.....:"/*cText>*/     ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux/*cText>*/   ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(aDados[1][18], "@R 99.999.999/9999-99"))
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "CNPJ.........:"/*cText>*/     ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux/*cText>*/  ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))
    oPrinter:Say ( nRow         , nColLabel+nCol2, "I.E.........:"/*cText>*/ ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2, cTxtAux/*cText>*/,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := AllTrim(aDados[1][13]) + '-' + AllTrim(aDados[1][14])
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Cidade.......:"/*cText>*/ ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux/*cText>*/         ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := AllTrim(aDados[1][17])
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Vendedor(a)..:"/*cText>*/ ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux/*cText>*/            ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTel := AllTrim(StrTran(aDados[1][15],'-',''))
    cTel := iif(len(cTel)>10,AllTrim(SubStr(cTel,3,10)),cTel)
    cTxtAux := Alltrim(Transform(cTel, iif( len(cTel)==10 ,"@R (99) 9999-9999", "@R 9999-9999")))

    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Fone.........:"/*cText>*/ ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux/*cText>*/   ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(SubStr(StrTran(aDados[1][16],'-',''),3), "@R (99) 9999-9999"))
    oPrinter:Say ( nRow         , nColLabel+nCol2, "Fax.........:"/*cText>*/,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo+nCol2, iif(AllTrim(cTxtAux)=='','',cTxtAux)/*cText>*/ ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := DtoC(sToD(aDados[1][19]))
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "Data Entrega.:"/*cText>*/ ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo, cTxtAux/*cText>*/      ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )

    oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, , cBoxPixel/*cPixel*/ )
    
    HeaderGrid()
    
    for nI := 1 to len(aDados)
        if FimPagina(1) // Verifica se a página está no final
            HeaderGrid()
        else 
            oPrinter:Say ( nRow+=nTamLin - 6, nColLabel      , aDados[nI][6]/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
            nGridLine := nRow
            lpula := .f.
            if len(AllTrim(aDados[nI][2])) > 45
                cTxtAux := AllTrim(aDados[nI][2])
                while AllTrim(cTxtAux) != ''
                    nAt     := At(" ",cTxtAux,45)
                    nPos    := Iif(len(cTxtAux)>40,Iif(nAt==0,len(cTxtAux),nAt),len(cTxtAux))
                    cDesc   := SubStr(cTxtAux,1,nPos)
                    cTxtAux := AllTrim(SubStr(cTxtAux,nPos+1,len(cTxtAux)))
                
                    oPrinter:Say ( iif(lPula,nRow+=nTamLin-10,nRow)   , nColLabel+50      , cDesc/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
                    lPula := .t.
                enddo 
            else        
                oPrinter:Say ( nRow   , nColLabel+50      , aDados[nI][2]/*cText>*/,oFGrid /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
            endif
            nRow := iif(nGridLine < nRow,nGridLine,nRow)
                
            cTxtAux := AllTrim(Transform(aDados[nI][08], "@r 999,999,999"))
            oPrinter:box ( nRow - 10, nBoxRight-255 , nRow , nBoxRight-220, cBoxPixel)
            oPrinter:Say ( nRow - 2 , nBoxRight-253 , cTxtAux /*cText>*/,oFBar /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
            
            cTxtAux := aDados[nI][07]
            oPrinter:box ( nRow - 10, nBoxRight-215 , nRow , nBoxRight-200, cBoxPixel)
            oPrinter:Say ( nRow - 2  , nBoxRight-213 , cTxtAux/*cText>*/,oFBar /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
            
            oPrinter:box ( nRow - 10         , nBoxRight-195 , nRow , nBoxRight-160, cBoxPixel)
            oPrinter:box ( nRow - 10         , nBoxRight-155 , nRow , nBoxRight-120, cBoxPixel)
            oPrinter:box ( nRow - 10         , nBoxRight-115 , nRow , nBoxRight-80 , cBoxPixel)
            oPrinter:box ( nRow - 10         , nBoxRight-75  , nRow , nBoxRight-40 , cBoxPixel)
            
            oPrinter:box ( nRow - 10  , nBoxRight-35  , nRow, nBoxRight-5  , cBoxPixel:="-4")
            oPrinter:Line( iif(nGridLine > nRow, nRow := nGridLine+=nTamLin-8,nRow+=nTamLin-8)/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
        endif 
    next nI
    
    FimPagina(2)// Verifica se a página está no final
    oPrinter:Say ( nRow+=nTamLin   , nColLabel     , "Valor Total: "/*cText>*/,oFInfoOBS /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:box ( nRow - 10       , nBoxRight-115 , nRow, nBoxRight-80 , cBoxPixel:="-4")
    oPrinter:Line( nRow+=nTamLin-10, nBoxCol       , nRow, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
    
    //FimPagina(2)// Verifica se a página está no final
    FimPagina(3)// Verifica se a página está no final
    oPrinter:Say ( nRow+=nTamLin, nColLabel , "Local de Entrega....:"/*cText>*/ ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + 50  , SM0->M0_NOMECOM /*cText>*/    ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := AllTrim( SM0->M0_ENDENT )
    oPrinter:Say ( nRow+=nTamLin, nColLabel , "Endereço de Entrega.:"/*cText>*/ ,oFLabel /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + 50  , cTxtAux /*cText>*/    ,oFInfo /*oFont*/ , /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    cTxtAux := Alltrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+' / '+Alltrim(Transform(SM0->M0_INSC, "@R 999.999.999.999"))
    oPrinter:Say ( nRow+=nTamLin, nColLabel,  "CNPJ / IE...........:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColInfo + 50, cTxtAux/*cText>*/            , oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel, "OBS: COTAÇÃO"/*cText>*/   , oFInfoOBS/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Line( nRow+=nTamLin-10, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
    
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Condições de Fornecimentos:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Pagamento:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColLabel+nCol2   , "Frete por conta:  ( ) Emitente  ( ) Destinatário  ( ) A Retirar"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Entrega Local:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow+=nTamLin, nColLabel         , "Prazo Entrega:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColLabel+nCol2   , "Frete:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )

    oPrinter:Say ( nRow+=nTamLin, nColLabel+nCol2+20, "Local de Entrega:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    nRow+=nTamLin
    oPrinter:Say ( nRow+=nTamLin,nColLabel+nCol2+20, "Local de Entrega:"/*cText>*/   , oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    
    cTxtAux := "Página " + Alltrim(Str(nNumPag+=1))
    oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-9,nColLabel   , "Agropecuária Vista Alegre LTDA"/*cText>*/   , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-9,nBoxRight-50, cTxtAux/*cText>*/  , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
Return

Static Function HeaderGrid()
    oPrinter:Say ( nRow+=nTamLin, nColLabel     , "CÓDIGO"/*cText>*/    ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nColLabel+50  , "PRODUTO"/*cText>*/   ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nBoxRight-195 , "VALOR"/*cText>*/     ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nBoxRight-75  , "VALOR"/*cText>*/     ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow         , nBoxRight-35  , "PRAZO"/*cText>*/     ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    
    oPrinter:Say ( nRow+=nTamLin - 6, nBoxRight-255 , "QTDE"/*cText>*/      ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow             , nColLabel     , "INTERNO"/*cText>*/   ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow             , nBoxRight-215 , "UND"/*cText>*/       ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow             , nBoxRight-195 , "UNITÁRIO"/*cText>*/  ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow             , nBoxRight-155 , "IMPOSTO"/*cText>*/   ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow             , nBoxRight-115 , "TOTAL"/*cText>*/     ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow             , nBoxRight-75  , "MARCA"/*cText>*/     ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Say ( nRow             , nBoxRight-35  , "ENTREGA"/*cText>*/   ,oFheader /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
    oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /* cColor */, cBoxPixel/*cPixel*/ )
Return 

Static Function FimPagina(nLocal)
    Local nDif
    Local lRet  := .F. 

    if nLocal == 1
        nDif := 20
    elseif nLocal == 2
        nDif := 10
        //nDif := 260
    else
        nDif := 200
    endif

    if (nBoxBottom - nRow) < nDif
        cTxtAux := "Página " + Alltrim(Str(nNumPag+=1))
        oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nColLabel   , "Agropecuária Vista Alegre LTDA"/*cText>*/   , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
        oPrinter:Say ( ((nTamLin*nTotLinha)*0.92)-10,nBoxRight-50, cTxtAux/*cText>*/  , oFInfo/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )

        oPrinter:EndPage()
        oPrinter:startpage()
        nRow := 30
        oPrinter:Box( nRow*0.4, nBoxCol:=nColLabel*0.4, nBoxBottom:=(nTamLin*nTotLinha)*0.90, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
        nRow := 15
        lRet := !lRet
    endif

Return lRet

/* Static Function fGetDados()
    Local aArea     := GetArea()
    Local aDados    := {}
    Local _cQry     := ''

    _cQry := " select C8_FILENT,C8_ITEM, " + CRLF 
    _cQry += " 		C8_FORNECE, " + CRLF 
    _cQry += " 		C8_LOJA, " + CRLF 
    _cQry += " 		C8_UM, " + CRLF 
    _cQry += " 		C8_PRODUTO, " + CRLF 
    _cQry += " 		C8_QUANT,  " + CRLF 
    _cQry += " 		C8_EMISSAO, " + CRLF 
    _cQry += " 		C8_NUM, " + CRLF 
    _cQry += " 		C8_NUMSC, " + CRLF 
    _cQry += " 		C8_DATPRF, " + CRLF 
    _cQry += " 		ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C8_MSGMAIL)),'') AS MSGMAIL , " + CRLF 
    _cQry += " 		C8_WFEMAIL " + CRLF 
    _cQry += " 		C8_NUM, " + CRLF 
    _cQry += " 		A2_NOME, " + CRLF 
    _cQry += " 		A2_END, " + CRLF
    _cQry += " 		A2_EST, " + CRLF 
    _cQry += " 		A2_TEL, " + CRLF
    _cQry += " 		A2_FAX, " + CRLF
    _cQry += " 		A2_EMAIL, " + CRLF 
    _cQry += " 		A2_MUN, " + CRLF 
    _cQry += " 		A2_CGC, " + CRLF 
    _cQry += " 		A2_COD_MUN, " + CRLF 
    _cQry += " 		A2_CONTATO, " + CRLF 
    _cQry += " 		B1_DESC, " + CRLF 
    _cQry += " 		C1_CODCOMP, " + CRLF 
    _cQry += " 		Y1_EMAIL " + CRLF 
    _cQry += " from "+RetSqlName("SC8")+" C8 " + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SB1")+" B1 ON C8_PRODUTO = B1_COD " + CRLF 
    _cQry += " AND B1.D_E_L_E_T_ = '' " + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SA2")+" A2 ON C8_FORNECE = A2_COD " + CRLF
    _cQry += " AND C8_LOJA = A2_LOJA" + CRLF 
    _cQry += " AND A2.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " LEFT JOIN "+RetSqlName("SC1")+" C1 ON C8_FILIAL = C1_FILIAL  " + CRLF 
    _cQry += " AND C8_NUMSC = C1_NUM  " + CRLF 
    _cQry += " AND C8_ITEMSC = C1_ITEM " + CRLF 
    _cQry += " AND C8_PRODUTO = C1_PRODUTO " + CRLF 
    _cQry += " AND C1.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " LEFT join "+RetSqlName("SY1")+" Y1 ON Y1_COD = C1_CODCOMP " + CRLF 
    _cQry += " AND Y1.D_E_L_E_T_ = ''" + CRLF 
    _cQry += " WHERE C8_FILIAL = '"+FWxFilial("SC8")+"' " + CRLF 
    _cQry += " AND C8_NUM = '"+aSolicit[1]+"' " + CRLF 
    _cQry += " AND C8_FORNECE+C8_LOJA = '"+aSolicit[2]+"' " + CRLF 
    _cQry += " AND C8_NUMPRO = '"+aSolicit[3]+"' " + CRLF 
    _cQry += " AND C8.D_E_L_E_T_ = '' "   + CRLF
    
    MemoWrite("C:\totvs_relatorios\" +"VACOMR10" + ".sql" , _cQry)
    
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)

    While !TEMPSQL->(Eof())
        aAdd(aDados,{TEMPSQL->C8_ITEM,;     //01    
                    TEMPSQL->B1_DESC,;      //02
                    TEMPSQL->C8_FILENT,;    //03
                    TEMPSQL->C8_FORNECE,;   //04
                    TEMPSQL->A2_NOME,;      //05
                    TEMPSQL->C8_PRODUTO,;   //06
                    TEMPSQL->C8_UM,;        //07
                    TEMPSQL->C8_QUANT,;     //08
                    TEMPSQL->C8_EMISSAO,;   //09
                    TEMPSQL->C8_NUM,;       //10
                    TEMPSQL->C8_NUMSC,;     //11
                    TEMPSQL->A2_END,;       //12
                    TEMPSQL->A2_MUN,;       //13
                    TEMPSQL->A2_EST,;       //14
                    TEMPSQL->A2_TEL,;       //15
                    TEMPSQL->A2_FAX,;       //16
                    TEMPSQL->A2_CONTATO,;   //17
                    TEMPSQL->A2_CGC,;       //18
                    TEMPSQL->C8_DATPRF,;    //19
                    TEMPSQL->A2_EMAIL,;     //20
                    TEMPSQL->C8_LOJA,;      //21
                    TEMPSQL->MSGMAIL,;      //22
                    })
        TEMPSQL->(dbSkip())
    enddo
    TEMPSQL->(dbCloseArea())
    RestArea(aArea)
Return aDados 
 */
Static Function SendMail()
    Local aArea     := GetArea()
    Local cMessage  := ""
    Local cWFID
    Local x
    Local lEnvia    := .T. 

    DbSelectArea("SY1")
    DbSetOrder(3) // Y1_FILIAL+Y1_USER
    DbSeek(xFilial("SY1")+__cUserID)
    
    DbSelectArea("SC8")
    DbSetOrder(1) // C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
    
    cMessage := iif(Val(SubStr(Time(),1,2))<12,"Bom dia!! <br>",iif(Val(SubStr(Time(),1,2))>18,"Boa Noite!! <br>","Boa Tarde!! <br>")) + CRLF 
    cMessage += "<br>"  + CRLF
    cMessage += "Segue em anexo, a solicitação de Orçamento! <br>" + CRLF
    cMessage += "Por Gentileza informar Preço, Forma de Pagamento, Frete e Prazo de Entrega.<br>" + CRLF
    if !Empty(aDados[1][22])
        For x := 1 to len(aDados[1][22])
            if AllTrim(SubStr(aDados[1][22],x,5)) != "."
                cMessage += SubStr(aDados[1][22],x,1)
            else
                cMessage += ".<br>" + CRLF 
            endif
            if AllTrim(SubStr(aDados[1][22],x,Len(aDados[1][22]))) == ""
                exit
            endif
        next x   
    endif 
    cMessage += "<br>" + CRLF 
    cMessage += "Desde já, agradeço.<br>" + CRLF
    cMessage += "<br>" + CRLF
    cMessage += "Atenciosamente,<br>" + CRLF
    cMessage += "<br>" + CRLF
    cMessage += ALLTRIM(SY1->Y1_NOME) + "<br>" + CRLF
    cMessage += ALLTRIM(SY1->Y1_TEL) + "<br>" + CRLF
    cMessage += ALLTRIM(SY1->Y1_EMAIL) + "<br>" + CRLF
    cMessage += "<br>" + CRLF
    cMessage += "www.vistaalegre.agr.br" + CRLF
    
    begin transaction 
        cWFID := u_GetWFID()

        if SC8->(DbSeek(SubStr(cKey,1,21)+"0001"+SubStr(cKey,22,2)))
            //RecLock("SC8",.f.)
                while cKey != SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_FORNECE+SC8->C8_LOJA+SC8->C8_NUMPRO
                    if Empty(Posicione("SA2",1,xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA,"A2_EMAIL"))
                        ShowHelpDlg("WFPROC01", {"O e-mail do fornecedor não está preenchido."}, 1, {"Por favor, preencha o e-mail do fornecedor "+SA2->A2_COD+" e use a rotina de o reenvio da cotação em atualização de cotações."}, 1 )
                        lEnvia := .f.
                    endif
                    if lEnvia
                        RecLock('SC8', .f.)
                        SC8->C8_WFCO   := "1"
                        if Empty(SC8->C8_WFDT)
                            SC8->C8_WFDT   := dDataBase
                        endif
                        
                        if empty(SC8->C8_WFEMAIL)
                            if cUsername == "Administrador"
                                cMailSend :=  "igor.oliveira@vistaalegre.agr.br"
                                //cMailSend :=  GetMV("MV_RELACNT")
                            else
                                PswOrder(1)
                                PswSeek(__cUserId)
                                //cMailSend :=  "igor.oliveira@vistaalegre.agr.br"
                                cMailSend := Iif(Empty(SY1->Y1_EMAIL), PswRet(1)[1][14], AllTrim(SY1->Y1_EMAIL))
                            endif
                        endif
                    endif
                    SC8->(DBSkip())
                ENDDO
            MSUNLOCK()
        endif

        cMessage := StrTran(cMessage, "{%NUMCOT%}", SubStr(cKey, TamSX3("C8_FILIAL")[1]+1,TamSX3("C8_NUM")[1]))
        u_EnvMail(cMailFornece/* "igor.oliveira@vistaalegre.agr.br" */, /*_cCc*/, /*_cBCC*/, "Solicitação de proposta de cotação V@ " + SubStr(cKey, 1, TamSX3("C8_FILIAL")[1] + TamSX3("C8_NUM")[1]) + ".", {cServPath + cArqName + ".pdf"}, cMessage, /*_lAudit*/)
    
    end Transaction 
    
    RestArea(aArea)
Return 
