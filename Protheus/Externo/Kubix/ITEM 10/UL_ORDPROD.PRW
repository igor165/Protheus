#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "rptdef.ch"

#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

//+--------------------------------------------------------------------+
//| Funcao | EBOP   | Autor | Vagner Azanha      | Data | 12/08/2020   |
//+--------------------------------------------------------------------+
//| Descr. | IMpressao de Ordem de Produção                            |
//+--------------------------------------------------------------------+
//| Uso    | PCP		                                               |
//+--------------------------------------------------------------------+
User Function UL_ORDPROD()
  Local oReport

  Private cFile := "op_"+_cOpIni+"a"+_cOpFim  
  Private nLimiteHor 
  Private nLimiteVer 
  Private aColImp := {}
  Private oFont07   := TFont():New("Arial",, 07,, .F.,,,,, .F., .F.)
  Private oFont08   := TFont():New("Arial",, 08,, .F.,,,,, .F., .F.)
  Private oFont09   := TFont():New("Arial",, 09,, .F.,,,,, .F., .F.)
  Private oFont11   := TFont():New("Arial",, 11,, .F.,,,,, .F., .F.)
  Private oFont08N  := TFont():New("Arial",, 08,, .T.,,,,, .F., .F.)
  Private oFontAri9	:= TFont():New("Arial",07, 009,,.T.,,,,,.F.,.F.) 
  Private oFontAri2	:= TFont():New("Arial",08, 011,,.F.,,,,,.F.,.F.) 
  Private oFontAri3	:= TFont():New("Arial",08, 008,,.F.,,,,,.F.,.F.) 
  Private oFontAr25 := TFont():New("Arial",14, 015,,.T.,,,,,.F.,.F.)
  Private oFont10   := TFont():New("Arial",, 10,, .F.,,,,, .F., .F.)
  Private oFont10N  := TFont():New("Arial",, 10,, .T.,,,,, .F., .F.)
  Private oFont11CN := TFont():New("Calibri",, 11,, .T.,,,,, .F., .F.)
  Private oFont10NS := TFont():New("Arial",, 10,, .T.,,,,, .T., .F.)
  //Private oFont11   := TFont():New("Arial",, 11,, .F.,,,,, .F., .F.)
  Private oFont12   := TFont():New("Arial",, 12,, .F.,,,,, .F., .F.)
  Private oFont12N  := TFont():New("Arial",, 12,, .T.,,,,, .F., .F.)
  Private oFont13  := TFont():New("Arial",, 13,, .F.,,,,, .F., .F.)
  Private oFont12CN := TFont():New("Calibri",, 12,, .T.,,,,, .F., .F.)
  Private oFont14   := TFont():New("Arial",, 14,, .F.,,,,, .F., .F.)
  Private oFont14N  := TFont():New("Arial",, 14,, .T.,,,,, .F., .F.)
  Private oFont14NI := TFont():New("Arial",, 14,, .T.,,,,, .F., .T.)
  Private oFont18N  := TFont():New("Arial Black",, 18,, .T.,,,,, .F., .F.)
  Private oFont20N  := TFont():New("Arial Black",, 20,, .T.,,,,, .F., .F.)
  Private oFont22N  := TFont():New("Arial Black",, 22,, .T.,,,,, .F., .F.) 
  Private oFont26N  := TFont():New("Arial Black",, 26,, .T.,,,,, .F., .F.)
  Private oFont36N  := TFont():New("Arial Black",, 36,, .T.,,,,, .F., .F.)
  Private oBrush    := TBrush():New(, 4)

  oReport := ReportDef()
  oReport:PrintDialog()
 
Return()

Static Function ReportDef()
    Local oEpi
	//Local oOpera
    //Local oCabOp
	Local oCabec
	//Local oLotes
	Local oObs
    Local oRotCbOpe
    Local oProcPrd
	Local oRepDef
    Local oEspFim
    //Local nI

    Private aColImp   := {}
    Private _cNumOP

	oRepDef := TReport():New(cFile,"Relatório de Ordens de Produção",NIL,;
	                         {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir o Ordem de Produção")
	oRepDef:SetPortrait()
    oRepDef:lHeaderVisible := .F.
    oRepDef:lFooterVisible := .F.
    
	//                       <oParent> , <cTitle> , <uTable> , <aOrder> , <lLoadCells> , <lLoadOrder> , <uTotalText> , <lTotalInLine> , <lHeaderPage> , <lHeaderBreak> , <lPageBreak> , <lLineBreak> , <nLeftMargin> , <lLineStyle> , <nColSpace> , <lAutoSize> , <cCharSeparator> , <nLinesBefore> , <nCols> , <nClrBack> , <nClrFore> , <nPercentage> )
    oCabec := TRSection():New(oRepDef,"CABEC1"  ,          ,          ,              ,              ,              ,                ,                ,               ,                ,              ,              ,               ,             ,   .T.         ,                   ,               ,          ,           ,            ,               )
    oCabec:SetHeaderSection(.F.) 
    
    TRCell():New (oCabec, "CABEC1", NIL          , NIL           , NIL        ,2500 , NIL       , NIL     , "LEFT"   , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
    oCabec:Cell("CABEC1"):oFontBody := oFont12	

   TRCell():New (oCabec, "CABEC2", NIL          , NIL           , NIL        ,200 , NIL       , NIL     , "LEFT"   , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
   oCabec:Cell("CABEC2"):oFontBody := oFont14N	



    //+--------------------------------------------------------------------+
	//| Secao Observacao
	//+--------------------------------------------------------------------+
    oObs := TRSection():New(oRepDef,"OBSERVACAO")
	oObs:SetHeaderSection(.F.) 

    TRCell():New ( oObs  , "OBS1"  , NIL      , NIL     ,            ,2000       ,          ,          ,          ,    .T.        ,                ,              ,             ,             ,            ,            ,         )
    TRCell():New ( oObs  , "OBS2"  , NIL      , NIL     ,            ,10       ,          ,          ,          ,    .T.        ,                ,              ,             ,             ,            ,            ,         )
	 
    oObs:Cell("OBS1"):oFontBody := oFont12 //**
    oObs:Cell("OBS2"):oFontBody := oFont12 //**

	//+--------------------------------------------------------------------+
	//| Secao EPIs
	//+--------------------------------------------------------------------+
    oEpi := TRSection():New(oRepDef    ,"EPI"    ,          ,          ,              ,              ,              ,                ,                ,               ,              ,  .T.         ,              ,               ,             ,   .T.         ,                   ,               ,          ,           ,            ,               )
    //                      <oParent> , <cTitle> , <uTable> , <aOrder> , <lLoadCells> , <lLoadOrder> , <uTotalText> , <lTotalInLine> , <lHeaderPage> , <lHeaderBreak> , <lPageBreak> , <lLineBreak> , <nLeftMargin> , <lLineStyle> , <nColSpace> , <lAutoSize> , <cCharSeparator> , <nLinesBefore> , <nCols> , <nClrBack> , <nClrFore> , <nPercentage> )
	oEpi:SetHeaderSection(.F.) 

    TRCell():New ( oEpi  , "EPI1"  , NIL      , NIL     ,              ,  135     ,          ,          ,          ,    .T.        ,                ,              ,             ,             ,            ,            ,         )
    //TRCell():New ( oEpi  , "EPI2"  , NIL      , NIL     ,            ,02         ,          ,          ,          ,    .T.        ,                ,              ,             ,             ,            ,            ,         )

    oEpi:Cell("EPI1"):oFontBody := oFont14 //**
   // oEpi:Cell("EPI2"):oFontBody := oFont12 //**


	//+--------------------------------------------------------------------+
	//| Secao Especificação Final
	//+--------------------------------------------------------------------+
	oEspFim := TRSection():New(oRepDef,"ESPFIN"   ,          ,          ,              ,              ,              ,                ,                ,               ,              ,  .F.         ,              ,               ,             ,   .T.         ,                   ,               ,          ,           ,            ,               )
	oEspFim:SetHeaderSection(.F.) 
 
    TRCell():New (oEspFim, "ESPFIN1", NIL      , NIL     ,              ,  4000     ,          ,          ,          ,    .T.        ,                ,              ,             ,             ,            ,            ,         )
	oEspFim:Cell("ESPFIN1"):oFontBody := oFont14 //**

    TRCell():New (oEspFim, "ESPFIN2", NIL      , NIL     ,              ,  120     ,          ,          ,          ,     .T.       ,                ,              ,             ,             ,            ,            ,         )
	oEspFim:Cell("ESPFIN2"):oFontBody := oFont14 //**

    TRCell():New (oEspFim, "ESPFIN3", NIL      , NIL     ,              ,  100     ,          ,          ,   "RIGHT"       ,   .T.         ,                ,              ,             ,             ,            ,            ,         )
	oEspFim:Cell("ESPFIN3"):oFontBody := oFont14 //**

    TRCell():New (oEspFim, "ESPFIN4", NIL      , NIL     ,              ,  25     ,          ,          ,  "RIGHT"        ,            ,                ,              ,             ,             ,            ,            ,         )
	oEspFim:Cell("ESPFIN4"):oFontBody := oFont14 //**

    TRCell():New (oEspFim, "ESPFIN5", NIL      , NIL     ,              ,  25     ,          ,          ,  "RIGHT"      ,    .T.        ,                ,              ,             ,             ,            ,            ,         )
	oEspFim:Cell("ESPFIN5"):oFontBody := oFont14 //**

    TRCell():New (oEspFim, "ESPFIN6", NIL      , NIL     ,              ,  100     ,          ,          ,          ,    .T.        ,                ,              ,             ,             ,            ,            ,         )
	oEspFim:Cell("ESPFIN6"):oFontBody := oFont14 //**
    
	
	//+--------------------------------------------------------------------+
	//| Secao Componentes da Estrutra
	//+--------------------------------------------------------------------+
	oEstrut := TRSection():New(oRepDef,"ESTRUT")
	oEstrut:SetHeaderSection(.F.) 
 
    TRCell():New (oEstrut, "ESTRUT1", NIL, NIL, /*cPicture*/,50, /*lPixel*/ , /*bBlock*/ )
	oEstrut:Cell("ESTRUT1"):oFontBody := oFont12 //**

    TRCell():New (oEstrut, "ESTRUT2", NIL, NIL, /*cPicture*/,400 /*lPixel*/ , /*bBlock*/ )
	oEstrut:Cell("ESTRUT2"):oFontBody := oFont12 //**

    TRCell():New (oEstrut, "ESTRUT3", NIL, NIL, /*cPicture*/,15, /*lPixel*/ , /*bBlock*/ )
	oEstrut:Cell("ESTRUT3"):oFontBody := oFont12 //**

    TRCell():New (oEstrut, "ESTRUT4", NIL, NIL, /*cPicture*/,50,  NIL       , NIL     , "RIGHT"   , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
	oEstrut:Cell("ESTRUT4"):oFontBody := oFont12 //**

    TRCell():New (oEstrut, "ESTRUT5", NIL, NIL, /*cPicture*/,40, /*lPixel*/ , /*bBlock*/ )
	oEstrut:Cell("ESTRUT5"):oFontBody := oFont12 //**

    TRCell():New (oEstrut, "ESTRUT6", NIL          , NIL           , NIL        ,45 , NIL       , NIL     , "LEFT"   , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
    oEstrut:Cell("ESTRUT6"):oFontBody := oFont12 //**

    TRCell():New (oEstrut, "ESTRUT7", NIL          , NIL           , NIL        ,25 , NIL       , NIL     , "LEFT"   , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
    oEstrut:Cell("ESTRUT7"):oFontBody := oFont12 //**


    //+--------------------------------------------------------------------+
	//| Secao Cabecalho de Roteiro de Operações
	//+--------------------------------------------------------------------+

	//oRotCbOpe := TRSection():New(oRepDef,"ROTCABOPER", , , , , , , , , , , , , , , , , , CLR_HGRAY , , ) 
    oRotCbOpe := TRSection():New(oRepDef  ,"ROTCABOPER"  ,          ,          ,              ,              ,              ,                ,                ,               ,               ,              ,              ,              ,             ,   .T.       ,                 ,                ,          ,           ,             ,               )
    //                          <oParent> , <cTitle>     , <uTable> , <aOrder> , <lLoadCells> , <lLoadOrder> , <uTotalText> , <lTotalInLine> , <lHeaderPage> , <lHeaderBreak> , <lPageBreak> , <lLineBreak> , <nLeftMargin> , <lLineStyle> , <nColSpace> , <lAutoSize> , <cCharSeparator> , <nLinesBefore> , <nCols> , <nClrBack> , <nClrFore> , <nPercentage> )
	oRotCbOpe:SetHeaderSection(.F.) 
        
    TRCell():New (oRotCbOpe, "ROTCBOPER1", NIL, NIL, /*cPicture*/,80, /*lPixel*/ , /*bBlock*/, , , , , ,.F. )
    oRotCbOpe:Cell("ROTCBOPER1"):oFontBody := oFont12 //** 

    TRCell():New (oRotCbOpe, "ROTCBOPER2", NIL, NIL, /*cPicture*/,2, /*lPixel*/ , /*bBlock*/, , , , , ,.F. )
	oRotCbOpe:Cell("ROTCBOPER2"):oFontBody := oFont12 //** 
    
    TRCell():New (oRotCbOpe, "ROTCBOPER3", NIL, NIL, /*cPicture*/,300, /*lPixel*/ , /*bBlock*/, , , , , ,.F. )
	oRotCbOpe:Cell("ROTCBOPER3"):oFontBody := oFont12 //** 

    TRCell():New (oRotCbOpe, "ROTCBOPER4", NIL, NIL, /*cPicture*/,50, /*lPixel*/ , /*bBlock*/, , , , , ,.F. )
	oRotCbOpe:Cell("ROTCBOPER4"):oFontBody := oFont12 //** 

    TRCell():New (oRotCbOpe, "ROTCBOPER5", NIL          , NIL           , NIL        ,50 , NIL       , NIL     , "RIGHT"   , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
	oRotCbOpe:Cell("ROTCBOPER5"):oFontBody := oFont12 //** 

    TRCell():New (oRotCbOpe, "ROTCBOPER6", NIL          , NIL           , NIL        ,50 , NIL       , NIL     , "LEFT"    , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
	oRotCbOpe:Cell("ROTCBOPER6"):oFontBody := oFont12 //** 
    
    TRCell():New (oRotCbOpe, "ROTCBOPER7", NIL          , NIL           , NIL        ,80 , NIL       , NIL     , "RIGHT"   , NIL          , NIL           , NIL          ,  NIL         , NIL        , NIL         , NIL        , NIL     )
	oRotCbOpe:Cell("ROTCBOPER7"):oFontBody := oFont12 //** 

     //+--------------------------------------------------------------------+
	//| Procedimento de Produção
	//+--------------------------------------------------------------------+
    oProcPrd := TRSection():New(oRepDef ,"PROCPROD",          ,          ,              ,              ,              ,                ,               ,                ,              ,.T.           ,               ,             ,              ,             ,                  ,                ,         ,            ,            ,              ) 
                           // <oParent> , <cTitle> , <uTable> , <aOrder> , <lLoadCells> , <lLoadOrder> , <uTotalText> , <lTotalInLine> , <lHeaderPage> , <lHeaderBreak> , <lPageBreak> , <lLineBreak> , <nLeftMargin> , <lLineStyle> , <nColSpace> , <lAutoSize> , <cCharSeparator> , <nLinesBefore> , <nCols> , <nClrBack> , <nClrFore> , <nPercentage>
    oProcPrd:SetHeaderSection(.F.) 
    //ProcPrd:SetCellBorder("RIGHT")


    TRCell():New (oProcPrd, "PROCPROD1", NIL      , NIL     ,            ,20         ,          ,          ,  ,    .F.        ,                ,              ,             ,             ,            ,            ,         )
    oProcPrd:Cell("PROCPROD1"):oFontBody := oFont12

 //   TRCell():New (oProcPrd, "PROCPROD2", NIL      , NIL     ,            ,2         ,          ,          ,  ,    .F.        ,                ,              ,             ,             ,            ,            ,         )
//    oProcPrd:Cell("PROCPROD2"):oFontBody := oFont12 

    TRCell():New (oProcPrd, "PROCPROD2", NIL      , NIL     ,             ,100        ,         ,          ,  ,    .T.       ,               ,              ,             ,             ,            ,            ,         )
    //           <oParent> , <cName>   , <cAlias> , <cTitle>, <cPicture>  , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) 
    oProcPrd:Cell("PROCPROD2"):oFontBody := oFont12 
/*
    TRCell():New (oProcPrd, "PROCPROD4" , NIL      , NIL     ,            ,18      ,          ,          , "RIGHT"   ,    .F.        ,                ,              ,             ,             ,            ,            ,         )
    oProcPrd:Cell("PROCPROD4"):oFontBody := oFont12 

    TRCell():New (oProcPrd, "PROCPROD5" , NIL      , NIL     ,            ,18    ,          ,          , "RIGHT"    ,    .F.        ,                ,              ,             ,             ,            ,            ,         )
    oProcPrd:Cell("PROCPROD5"):oFontBody := oFont12 

    TRCell():New (oProcPrd, "PROCPROD6", NIL      , NIL     ,             ,18      ,          ,          , "RIGHT"   ,    .F.        ,                ,              ,             ,             ,            ,            ,         )
    oProcPrd:Cell("PROCPROD6"):oFontBody := oFont12 

    TRCell():New (oProcPrd, "PROCPROD7", NIL      , NIL     ,             ,18      ,          ,          , "RIGHT"  ,    .F.        ,                ,              ,             ,             ,            ,            ,         )
    oProcPrd:Cell("PROCPROD7"):oFontBody := oFont12 
*/


    
    oRepDef:setFile(cFile)
    oRepDef:nDevice := IMP_PDF
   
   
Return(oRepDef)

Static Function PrintReport(oReport)

	//Local aDadosEst := {}
	//Local cCodBar2 	:= ""
	//Local cDescSet 	:= ""
	Local dEmissao 	:= STOD("")
	//Local nH	 	:= 0
	//Local nLinCM	:= 0
	//Local nLinha	:= 0
	//Local nColuna	:= 070
	//Local nDistCM	:= 0
	Local cQuery 	:= ""
	Local cdesc		:= ""
	//Local oFontAri9	:= TFont():New("Arial",08, 011,,.T.,,,,,.F.,.F.) 
	//Local oFontAr25	:= TFont():New("Arial",08, 020,,.T.,,,,,.F.,.F.) 
	Local cPedcCli	:= ""
	Local oCabec	:= oReport:Section(1)
	Local oObs	    := oReport:Section(2)
    Local oEpi      := oReport:Section(3)
    Local oEspFim   := oReport:Section(4)
    Local oEstrut   := oReport:Section(5)
    Local oRotCbOpe := oReport:Section(6)
    Local oProcPrd  := oReport:Section(7)
  
    //Local _nPag
    Local nI
    //Local _In
	//local oBrush1 := TBrush():New( , CLR_BLACK )  
	//local oBrush2 := TBrush():New( , CLR_WHITE )
    Local _nIndex
    Local _cQryOP
    Local _aPedObs := {}
    Local _cOpBar
    Local _cObsPed
    Local _aEpi := {}
    Local _cD4Dcqtd := 0
    Local _nAFI
    Local _nAFS

    Local _cEspFinal
    Local _cAmostra

    Local oQrCode := nil

    Private cFileLogo := GetSrvProfString('Startpath','') + 'LGRL01.BMP'
    Private _nLinCdBar
    Private _nLinIniBarCode 
    Private _lPriBarCode := .T.

    Private _nNumGrade
    Private _nNumColsGrades

    Private _cOpOrigem := "" 

    
    nLimiteHor  := oReport:PageWidth() - 0400
    nLimiteVer  := oReport:PageHeight() - 0100
    
    aAdd(aColImp, 30)
    nVlr := (nLimiteHor - 30) / 7
    For nI := 1 To 7
        aAdd(aColImp, aColImp[Len(aColImp)] + nVlr)
    Next nI

    // Query de OPs
    fQryOP(@_cQryOP)

    if select("TCSC2") <>0
        TCSC2->(dBCloseArea())
    endif
    TCQUERY _cQryOP NEW ALIAS "TCSC2"

    TCSC2->(dbgotop())

	do While TCSC2->(!EOF())

       _nNumGrade := TCSC2->C2_QUANT

       cQuery := "SELECT * FROM "+ RetSqlName("SC6") + " AS C6 " +CRLF
	   cQuery += "INNER JOIN "+ RetSqlName("SC5") + " AS C5 "+CRLF
	   cQuery += "ON C5.C5_FILIAL = C6.C6_FILIAL AND C5_NUM = C6_NUM "+CRLF
	   cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") +"' AND C6.C6_NUM = '" +TCSC2->C2_PEDIDO + "' AND C6_ITEM = '"+ TCSC2->C2_ITEMPV +"' AND C5.D_E_L_E_T_=' ' AND C6.D_E_L_E_T_=' ' "+CRLF
       cQuery += "AND C6.C6_PRODUTO = '"+TCSC2->C2_PRODUTO+"' "
     
       if select("TSC5") <>0
          TSC5->(dBCloseArea())
       endif
       TCQUERY cQuery NEW ALIAS "TSC5"
       
       cDesc     := TSC5->C6_DESCRI
       dEmissao := TSC5->C5_EMISSAO
       cPedcCli := TSC5->C6_PEDCLI

       cQuery := " SELECT C5.R_E_C_N_O_ AS C5REC,ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),C5_ZZOBS)),'') AS C5MEMO, *  FROM "+ RetSqlName("SC6") + " AS C6 " +CRLF
	   cQuery += " INNER JOIN "+ RetSqlName("SC5") + " AS C5 "+CRLF
	   cQuery += " ON C5.C5_FILIAL = C6.C6_FILIAL AND C5_NUM = C6_NUM "+CRLF
	   cQuery += "  WHERE C6_FILIAL = '" + xFilial("SC6") +"' AND C6.C6_NUM = '" +TCSC2->C2_PEDIDO + "' AND C6_ITEM = '"+ TCSC2->C2_ITEMPV +"'  AND C5.D_E_L_E_T_=' ' AND C6.D_E_L_E_T_=' ' "
      
       if select("TSC5") <>0
          TSC5->(dBCloseArea())
       endif
       TCQUERY cQuery NEW ALIAS "TSC5"

       SC5->(dbgoto(TSC5->C5REC))

       _aPedObs := {}
  
        _cNumOP     := TCSC2->C2_NUM+"/"+TCSC2->C2_ITEM+"/"+TCSC2->C2_SEQUEN 
        _cOpBar     := TCSC2->C2_NUM+TCSC2->C2_ITEM+TCSC2->C2_SEQUEN
        _cOpOrigem  := TCSC2->C2_NUM+TCSC2->C2_ITEM+TCSC2->C2_SEQUEN 
        nPag := 0
        ImpCab(oReport,.T.,oCabec,.F.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe)  // Primeira vez do Cabeçalho
    
        
        MSBAR4("CODE128",3.5 ,14.0          ,_cOpBar             ,@oReport:oPrint,NIL,NIL,NIL,6,1,.T.,NIL, ,.F.)
	    
        oReport:SetRow(620)
        oCabec:Cell("CABEC1"):oFontBody := oFont12N
        oCabec:Cell("CABEC1"):SetValue("OBSERVAÇÕES")
        oCabec:Cell("CABEC2"):SetValue("")
        oCabec:PrintLine()
        oReport:SkipLine()
        
        //MSMM(, TamSx3("C2_ZZOBS")[1],, &(SC2->C2_ZZOBS), 3, /* TamSize */,/* Wrap */, "SD3","D3_OBSERVA")

        SC2->(DBSELECTAREA( "SC2" ))
        SC2->(DBGOTO(TCSC2->R_E_C_N_O_ ))
        //MSMM(,TamSx3("C2_ZZOBS")[1],,&(SC2->C2_ZZOBS),3,,,"SC2","C2_ZZOBS")
        if !EMPTY(MSMM(,TamSx3("C2_ZZOBS")[1],,&(SC2->C2_ZZOBS),3,,,"SC2","C2_ZZOBS"))
            oCabec:Cell("CABEC1"):SetValue(ALLTRIM(TCSC2->C2_ZZOBS))
            oCabec:Cell("CABEC2"):SetValue("")
            oCabec:PrintLine()
        ENDIF 

        SC2->(DBCLOSEAREA( ))

        oReport:FatLine()

        // *** OBSERVACOES ****
        oObs:Init()
        oReport:SkipLine()
         
        _cObsPed:=""+chr(10)+chr(13)
        _cObsPed+=SC5->C5_ZZOBS+chr(10)+chr(13)
        _cObsPed+=chr(10)+chr(13)

	    oObs:Cell("OBS1"):SetValue(TSC5->C5MEMO)
        oObs:Cell("OBS2"):SetValue("")
        oObs:PrintLine()

        oReport:FatLine()
       
        oObs:Finish()

        // *** EPI ****
        _aEpi := {}
        oEpi:Init()
        oEpi:Cell("EPI1"):oFontBody := oFont12N
        oEpi:Cell("EPI1"):SetValue("EPI’s")
        //oEpi:Cell("EPI2"):SetValue("")

        oEpi:PrintLine()
        oEpi:Cell("EPI1"):oFontBody := oFont11

        fTrazEpi(@_aEpi)

        _cEpiOp := "" 

        for _nIndex := 1 to len(_aEpi)
           _cEpiOP+="  "+_aEpi[_nIndex]
        next
        
        oReport:SkipLine()
        oEpi:Cell("EPI1"):SetValue(_cEpiOp)
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()
        oReport:SkipLine()

        fEspFinal(TCSC2->C2_PRODUTO,@_cEspFinal,@_cAmostra)

        
        oEpi:Cell("EPI1"):oFontBody := oFont12N
        oEpi:Cell("EPI1"):SetValue("ESPECIFICAÇÃO ORGINAL")
        oEpi:PrintLine()

        oEpi:Cell("EPI1"):oFontBody := oFont12
        oEpi:Cell("EPI1"):SetValue(TESPFINAL->ESPORI)
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()
        oReport:ThinLine()
        oReport:SkipLine()

        oEpi:Cell("EPI1"):oFontBody := oFont12N
        oEpi:Cell("EPI1"):SetValue("ESPECIFICAÇÃO FINAL")
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()
        oEpi:Cell("EPI1"):oFontBody := oFont12

        oEspFim:Init()
        oEspFim:Cell("ESPFIN1"):oFontBody := oFont12N
        oEspFim:Cell("ESPFIN2"):oFontBody := oFont12N
        oEspFim:Cell("ESPFIN3"):oFontBody := oFont12N
        oEspFim:Cell("ESPFIN4"):oFontBody := oFont12N
        oEspFim:Cell("ESPFIN5"):oFontBody := oFont12N
        oEspFim:Cell("ESPFIN6"):oFontBody := oFont12N

        oEspFim:Cell("ESPFIN1"):SetValue("Ensaio")
        oEspFim:Cell("ESPFIN2"):SetValue("Desc.Un.Med")
        oEspFim:Cell("ESPFIN3"):SetValue("Nominal")
        oEspFim:Cell("ESPFIN4"):SetValue("A.F.I.")
        oEspFim:Cell("ESPFIN5"):SetValue("A.F.S.")
        oEspFim:Cell("ESPFIN6"):SetValue("Texto")
        oEspFim:PrintLine()
        oReport:SkipLine()

        oEspFim:Cell("ESPFIN1"):oFontBody := oFont12
        oEspFim:Cell("ESPFIN2"):oFontBody := oFont12
        oEspFim:Cell("ESPFIN3"):oFontBody := oFont12
        oEspFim:Cell("ESPFIN4"):oFontBody := oFont12
        oEspFim:Cell("ESPFIN5"):oFontBody := oFont12
        oEspFim:Cell("ESPFIN6"):oFontBody := oFont12

        do while TESPFINAL->(!eof())

            _nLse    :=  val(StrTran( TESPFINAL->LSE, ",", "." ))
            _nLie    :=  val(StrTran( TESPFINAL->LIE, ",", "." ))
            _nNomina :=  val(StrTran( TESPFINAL->NOMINA, ",", "." ))

            _nAFI := _nLse-_nNomina
            _nAFS := _nLie-_nNomina

            oEspFim:Cell("ESPFIN1"):SetValue(TESPFINAL->ENSAIO)
            oEspFim:Cell("ESPFIN2"):SetValue(TESPFINAL->UNDESC)
            oEspFim:Cell("ESPFIN3"):SetValue(TESPFINAL->NOMINA)
            oEspFim:Cell("ESPFIN4"):SetValue(transform(_nAFI,"@E 9,999"))
            oEspFim:Cell("ESPFIN5"):SetValue(transform(_nAFS,"@E 9,999"))
            oEspFim:Cell("ESPFIN6"):SetValue(TESPFINAL->TEXTO)
            oEspFim:PrintLine()        
            TESPFINAL->(dbskip())
        enddo

        oEspFim:Finish()
        oReport:ThinLine()
        oReport:SkipLine()

        oEpi:Cell("EPI1"):oFontBody := oFont12N
        oEpi:Cell("EPI1"):SetValue("ESPECIFICAÇÃO EMBALAGEM FINAL")
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()

        oEpi:Cell("EPI1"):oFontBody := oFont12
        oEpi:Cell("EPI1"):SetValue(TCSC2->ESPEMB)
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()
        oReport:ThinLine()
        oReport:SkipLine()
        

        oEpi:Cell("EPI1"):oFontBody := oFont12N
        oEpi:Cell("EPI1"):SetValue("TRATAMENTO DA EMBALAGEM/RESÍDUO")
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()

       oEpi:Cell("EPI1"):oFontBody := oFont12
        oEpi:Cell("EPI1"):SetValue(TCSC2->TRATEMB)
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()
        oReport:ThinLine()
        oReport:SkipLine()
        

        oEpi:Cell("EPI1"):oFontBody := oFont12N
        oEpi:Cell("EPI1"):SetValue("CONTROLE DE QUALIDADE")
       // oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()

        oEpi:Cell("EPI1"):oFontBody := oFont12
        oEpi:Cell("EPI1"):SetValue(_cAmostra)
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()
        oReport:FatLine()
     
        //*** COMPONENTES DA ESTRUTURA - EMPENHOS ***        
        oReport:SkipLine()
        oEpi:Cell("EPI1"):oFontBody := oFont12N
        oEpi:Cell("EPI1"):SetValue("COMPONENTES DA ESTRUTURA")
        //oEpi:Cell("EPI2"):SetValue("")
        oEpi:PrintLine()
        oEpi:Finish()

        oEstrut:Init()

        
        fAjuFonte(oEstrut,oFont12N,"ESTRUT",7)
        oEstrut:Cell("ESTRUT1"):SetValue("Componente")
        oEstrut:Cell("ESTRUT2"):SetValue("Descrição")
        oEstrut:Cell("ESTRUT3"):SetValue("UN")
        oEstrut:Cell("ESTRUT4"):SetValue("Qtde")
        oEstrut:Cell("ESTRUT5"):SetValue("Nº Lote")
        oEstrut:Cell("ESTRUT6"):SetValue("Endereço")
        oEstrut:Cell("ESTRUT7"):SetValue("Armazem")
        
        oEstrut:PrintLine()
        fAjuFonte(oEstrut,oFont12,"ESTRUT",7)

    
        oReport:SkipLine()

        cQuery:= "SELECT  SD4.D4_FILIAL,  SD4.D4_OP,SD4.D4_COD, SD4.D4_LOTECTL, SD4.D4_LOCAL,SDC.DC_LOCALIZ ,SUM(SD4.D4_QUANT) AS D4QUANT, SUM(SDC.DC_QUANT) AS DCQUANT "+CRLF
        cQuery+= "FROM "+RetSQLName("SD4")+" SD4 "+CRLF
        cQuery+= "LEFT JOIN "+RetSqlName("SDC")+" SDC ON (SDC.DC_FILIAL=SD4.D4_FILIAL AND SDC.DC_OP=SD4.D4_OP AND SDC.DC_PRODUTO=SD4.D4_COD AND SD4.D4_LOCAL=SDC.DC_LOCAL AND SD4.D4_LOTECTL=SDC.DC_LOTECTL AND SDC.DC_ORIGEM = 'SC2' AND SDC.D_E_L_E_T_=' ') "+CRLF
        cQuery+= "WHERE SD4.D4_FILIAL= '"+ Xfilial("SD4")+"' AND SD4.D_E_L_E_T_ = '' AND SD4.D4_OP='" + TCSC2->C2_NUM+TCSC2->C2_ITEM+TCSC2->C2_SEQUEN+"' "+CRLF
        cQuery+= "GROUP BY  SD4.D4_FILIAL, SD4.D4_OP, SD4.D4_COD, SD4.D4_LOTECTL, SD4.D4_LOCAL,SDC.DC_LOCALIZ "+CRLF
        cQuery+= "ORDER BY SD4.D4_FILIAL, SD4.D4_OP, SD4.D4_COD, SD4.D4_LOTECTL, SD4.D4_LOCAL,SDC.DC_LOCALIZ "+CRLF

        if select("TCSD4") <>0
            TCSD4->(dBCloseArea())
        endif
        TcQuery cQuery Alias TCSD4 New
        TCSD4->(dbgotop())
        
        do while TCSD4->(!Eof())

            if oReport:Row() > _nTotLinhas
                oReport:EndPage()
                ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.T.,oEstrut,.F.,oRotCbOpe) 
            endif

            if TCSD4->DCQUANT > 0 
                _cD4Dcqtd := TCSD4->DCQUANT
            else
                _cD4Dcqtd := TCSD4->D4QUANT
            endif    

            oEstrut:Cell("ESTRUT1"):SetValue(TCSD4->D4_COD)
            oEstrut:Cell("ESTRUT2"):SetValue(alltrim(Posicione("SB1",1,xFilial("SB1")+TCSD4->D4_COD,"B1_DESC")))
            oEstrut:Cell("ESTRUT3"):SetValue(alltrim(Posicione("SB1",1,xFilial("SB1")+TCSD4->D4_COD,"B1_UM")))
            oEstrut:Cell("ESTRUT4"):SetValue(alltrim(transform(_cD4Dcqtd,"@E 999,999,999.99")))            
            oEstrut:Cell("ESTRUT5"):SetValue(TCSD4->D4_LOTECTL)
            oEstrut:Cell("ESTRUT6"):SetValue(TCSD4->DC_LOCALIZ)
            oEstrut:Cell("ESTRUT7"):SetValue(alltrim(TCSD4->D4_LOCAL))
            
            
            oEstrut:PrintLine()
            oReport:SkipLine()

            TCSD4->(dbskip())
        enddo
        TCSD4->(dBCloseArea())
        oEstrut:Finish()
        
        oReport:FatLine()

        if oReport:Row() > _nTotLinhas
            oReport:EndPage()
            ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe) 
        endif

	    // *** ROTEIRO DE OPERAÇÕES ***
        
        oRotCbOpe:Init()
        fAjuFonte(oRotCbOpe,oFont12N,"ROTCBOPER",7)
        oRotCbOpe:Cell("ROTCBOPER1"):SetValue("ROTEIRO DE OPERAÇÃO") 
        oRotCbOpe:Cell("ROTCBOPER2"):SetValue("") 
        oRotCbOpe:Cell("ROTCBOPER3"):SetValue("")
        oRotCbOpe:Cell("ROTCBOPER4"):SetValue("")
        oRotCbOpe:Cell("ROTCBOPER5"):SetValue("")
        oRotCbOpe:Cell("ROTCBOPER7"):SetValue("")
        oRotCbOpe:PrintLine()    
        oReport:SkipLine()
      
        cQuery := "SELECT *, "+ CRLF
        cQuery += "ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),G2_ZZMEMO)),'') AS G2MEMO "		+CRLF
		cQuery += "FROM " +RetSqlName("SG2")+ " SG2"			+CRLF
		cQuery += "WHERE G2_FILIAL = '"+xFilial('SG2')+"'"		+CRLF
		cQuery += "AND G2_PRODUTO  = '" +TCSC2->C2_PRODUTO+ "'  "		+CRLF
		cQuery += "AND G2_CODIGO    = '" +TCSC2->C2_ROTEIRO+"'   "		+CRLF
		cQuery += "AND D_E_L_E_T_ = ''"							+CRLF
		cQuery += "ORDER BY G2_OPERAC"		
		
        if select("TCG2") <>0
            TCG2->(dBCloseArea())
        endif
        
        TCQUERY cQuery NEW ALIAS "TCG2"

        TCG2->(dbgotop())
        fAjuFonte(oRotCbOpe,oFont12N,"ROTCBOPER",7)
        oRotCbOpe:Cell("ROTCBOPER1"):SetValue("Sequência") 
        oRotCbOpe:Cell("ROTCBOPER2"):SetValue("") 
        oRotCbOpe:Cell("ROTCBOPER3"):SetValue("Descrição")
        oRotCbOpe:Cell("ROTCBOPER4"):SetValue("Recurso")
        oRotCbOpe:Cell("ROTCBOPER5"):SetValue("Desc")
        //oRotCbOpe:Cell("ROTCBOPER5"):SetValue("Qtd Oper.")
        oRotCbOpe:Cell("ROTCBOPER7"):SetValue("Tempo Estim.")
        oRotCbOpe:PrintLine()
        oReport:SkipLine()
        fAjuFonte(oRotCbOpe,oFont12,"ROTCBOPER",7)
        

        do while TCG2->(!eof())

            if oReport:Row() > _nTotLinhas
                oReport:EndPage()
                ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.F.,oEstrut,.T.,oRotCbOpe) 
            endif

            oRotCbOpe:Cell("ROTCBOPER1"):SetValue("")
            oRotCbOpe:Cell("ROTCBOPER2"):SetValue(TCG2->G2_OPERAC) 
            oRotCbOpe:Cell("ROTCBOPER3"):SetValue(TCG2->G2_DESCRI)
            oRotCbOpe:Cell("ROTCBOPER4"):SetValue(TCG2->G2_RECURSO)
            oRotCbOpe:Cell("ROTCBOPER5"):SetValue(alltrim(Posicione("SH1",1,FwxFilial("SH1")+TCG2->G2_RECURSO,"H1_DESCRI")))
            //oRotCbOpe:Cell("ROTCBOPER5"):SetValue(alltrim(transform(TCG2->G2_MAOOBRA,"@E 9,999.99")))
            oRotCbOpe:Cell("ROTCBOPER7"):SetValue(alltrim(transform(TCG2->G2_TEMPAD,"@E 999,999.99")))

            oRotCbOpe:PrintLine()

            //Cria o objeto FwQrCode
           //oQrCode := FwQrCode():New(20,20,150,150, oReport:oPrint, TCG2->G2_OPERAC )
           ////// oQrCode:SetCodeBar(cNewCod)
           //oQrCode:Refresh()

            fCodBarras(oReport, TCG2->G2_OPERAC)

            //fQrCode(oReport, oRotCbOpe,alltrim(TCG2->G2_ZZGOOGL),TCG2->G2_OPERAC,TCSC2->C2_NUM+TCSC2->C2_ITEM+TCSC2->C2_SEQUEN)
            fQrCode(oReport, oRotCbOpe,"google.com.br","123456","121345687")
   
            TCG2->(dbskip())
            
            oReport:SkipLine()
            oReport:ThinLine()
            oReport:SkipLine()
            oReport:SkipLine()
        
        enddo

       
       if oReport:Row() > _nTotLinhas
           oReport:EndPage()
           ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe) 
       endif        

        // *** Procedimento de Produção
        fAjuFonte(oRotCbOpe,oFont12N,"ROTCBOPER",7)
        oRotCbOpe:Cell("ROTCBOPER1"):SetValue("PROCEDIMENTOS DE PRODUÇÃO") 
        oRotCbOpe:Cell("ROTCBOPER2"):SetValue("") 
        oRotCbOpe:Cell("ROTCBOPER3"):SetValue("")
        oRotCbOpe:Cell("ROTCBOPER4"):SetValue("")
        oRotCbOpe:Cell("ROTCBOPER5"):SetValue("")
        oRotCbOpe:Cell("ROTCBOPER6"):SetValue("")
        oRotCbOpe:Cell("ROTCBOPER7"):SetValue("")
        oRotCbOpe:PrintLine()
       // oRotCbOpe:Finish()

       
       if oReport:Row() > _nTotLinhas
           oReport:EndPage()
           ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe) 
       endif

        oProcPrd:Init()
            
        fAjuFonte(oProcPrd,oFont12N,"PROCPROD",2)
        oProcPrd:Cell("PROCPROD1"):SetValue("Nº")
       //oProcPrd:Cell("PROCPROD2"):SetValue("Seq.")
        oProcPrd:Cell("PROCPROD2"):SetValue("Descrição")
       
       // oProcPrd:Cell("PROCPROD4"):SetValue("")
       // oProcPrd:Cell("PROCPROD5"):SetValue("")
       // oProcPrd:Cell("PROCPROD6"):SetValue("")
       // oProcPrd:Cell("PROCPROD7"):SetValue("")
        oProcPrd:PrintLine()
             
     
        oReport:SkipLine()

         
        fAjuFonte(oProcPrd,oFont12,"PROCPROD",2)
        
        _aProcProd := fProcPrd()
        _lPrim := .T.

        for _nIndex:= 1 to len(_aProcProd)
              
            if oReport:Row() > _nTotLinhas
                oReport:EndPage()
                ImpCab(oReport,.F.,oCabec,.T.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe) 
            endif

            if "ETAPA" $ alltrim(_aProcProd[_nIndex][2])
                fBarra(oReport,.T.,.T.,oProcPrd,_lPrim) 
                _lPrim := .F.
                oProcPrd:Cell("PROCPROD1"):SetValue(alltrim(_aProcProd[_nIndex][1]))
            else
                oProcPrd:Cell("PROCPROD1"):SetValue("")                      
            endif
            oProcPrd:Cell("PROCPROD2"):SetValue(alltrim(_aProcProd[_nIndex][2]))
            oProcPrd:PrintLine()
            
            if "ETAPA" $ alltrim(_aProcProd[_nIndex][2])
                oReport:SkipLine()
            endif

            //oReport:SkipLine()

           // if _nIndex < len(_aProcProd)
           //     oReport:FatLine()
          //  endif

           // oReport:SkipLine()

        next
        
       
        oProcPrd:Finish()
       
        TCG2->(dbclosearea())

        oRotCbOpe:Finish()
   
        oReport:SkipLine()

        oReport:FatLine()

        fBoxFinal(oReport,oCabec,oProcPrd,oEstrut,oRotCbOpe)


        TCSC2->(dbskip())

        if TCSC2->(EOF())
            TCSC2->(dbskip() -1)
            oReport:SkipLine()
            oReport:FatLine()

            fFinalPage(oReport,oCabec,oProcPrd,oEstrut,oRotCbOpe)

            oCabec:Finish()
            
            TCSC2->(dbskip())
        endif 

    enddo

 Return nil   

Static Function ImpCab(oReport,_lPrim,oCabec,_lProd,oProcPrd,_lEstrut,oEstrut,_lRotOper,oRotCbOpe)

    Local nQtd_Inteiro := 0

    If nPag != 1
        oReport:EndPage()
    EndIf

    //if _lPrim
       oReport:Box( 0000 , 0000 , 0600 , oReport:PageWidth() ) 
    //else
    // oReport:Box( 0000 , 0000 , 0200 , oReport:PageWidth() ) 
    //endif   
    // if _lPrim
    //   oReport:SetRow(210)
    //  else
      oReport:SetRow(210)
    // endif  
   
  
    oReport:SayBitmap(005,050,cFileLogo,500,150)
    oReport:Say(080, 600, "ULTRAFINE FAB2 - Ordem de Produção Nª : " + _cNumOp, oFont18N,,,,)
    oReport:Say(130, 600, DToC(Date()) + " - " + Time(), oFont10N,,,, PAD_LEFT)
    //oReport:Say(130, nLimiteHor+200, "Página: " + StrZero(oReport:Page(), 4), oFont10N,,,, PAD_RIGHT)

    // *** CABECALHO 1
    oCabec:Init()
    oCabec:Cell("CABEC1"):SetValue("Data Início Prevista : " + substr(TCSC2->C2_DATPRI,7,2)+;
                                    "/"+substr(TCSC2->C2_DATPRI,5,2)+;
                                    "/"+substr(TCSC2->C2_DATPRI,1,4)+;
                                    space(20)+;
                                    "Data Fim Efetiva : "+substr(TCSC2->C2_DATRF,7,2)+;
                                    "/"+substr(TCSC2->C2_DATRF,5,2)+;
                                    "/"+substr(TCSC2->C2_DATRF,1,4))
                                    //"/"+substr(TCSC2->C2_DATRF,1,4)+;
                                    //space(5)+;
                                    //"Lote Interno : "+ALLTRIM(TCSC2->C2_ZZLOTEC))
    oCabec:Cell("CABEC2"):SetValue("Lote Interno : "+ALLTRIM(TCSC2->C2_ZZLOTEC))
    //oCabec:Cell("CABEC2"):SetValue("Lote: "+alltrim(TCSC2->C2_ZZLOTEC))
    oCabec:PrintLine()
	oReport:SkipLine()

    oCabec:Cell("CABEC1"):oFontBody := oFont12N
    oCabec:Cell("CABEC1"):SetValue("Item: "+TCSC2->C2_PRODUTO+" "+TCSC2->B1_DESC )
    oCabec:Cell("CABEC2"):SetValue("Lote Mapa : "+ALLTRIM(TCSC2->C2_ZLOTSAP))
    //oCabec:Cell("CABEC2"):SetValue("")
   	oCabec:PrintLine()
	    
    oReport:SkipLine()
        
    oCabec:Cell("CABEC1"):oFontBody := oFont12
    oCabec:Cell("CABEC2"):oFontBody := oFont12

    nQtd_Inteiro := Int(TCSC2->C2_QUANT)
    
    if _lPrim
        If (TCSC2->C2_QUANT - nQtd_Inteiro) > 0
            oCabec:Cell("CABEC1"):SetValue("Qtd. Planejada :"+Transform(TCSC2->C2_QUANT,PesqPict("SC2","C2_QUANT"))+space(15)+"Qtd. Concluida :_______________")
        Else
            oCabec:Cell("CABEC1"):SetValue("Qtd. Planejada :"+Transform(nQtd_Inteiro,"@E 999,999,999")+space(15)+"Qtd. Concluida :_______________")
        EndIf
        oCabec:Cell("CABEC2"):SetValue("PERCA:_______________")
    else
        If (TCSC2->C2_QUANT - nQtd_Inteiro) > 0
            oCabec:Cell("CABEC1"):SetValue("Qtd. Planejada :"+transform(TCSC2->C2_QUANT,PesqPict("SC2","C2_QUANT")))
        Else
            oCabec:Cell("CABEC1"):SetValue("Qtd. Planejada :"+transform(nQtd_Inteiro,"@E 999,999,999"))
        EndIf
        oCabec:Cell("CABEC2"):SetValue("")
    endif    
    oCabec:PrintLine()
	oReport:SkipLine()

    IF !EMPTY(TCSC2->C2_ZZFIRST)
        oCabec:Cell("CABEC1"):oFontBody := oFont18N
        oCabec:Cell("CABEC1"):SetValue("FIRST FILL")
        oCabec:Cell("CABEC2"):SetValue("")
        oCabec:Cell("CABEC1"):oFontBody := oFont12
    else 
        //Cria o objeto FwQrCode
        // oQrCode := FwQrCode():New({20,20,150,150}, oReport, '1587535' )
        // oQrCode:Refresh()

        oCabec:Cell("CABEC1"):SetValue("")
        oCabec:Cell("CABEC2"):SetValue("")
    endif 
    oCabec:PrintLine()
    oReport:SkipLine()
    oReport:SkipLine()
    oReport:SkipLine()
    oReport:SkipLine()
    oReport:SkipLine()
    oReport:SkipLine()
    oReport:SkipLine()

    if _lProd
        fAjuFonte(oProcPrd,oFont12N,"PROCPROD",2)
        oProcPrd:Cell("PROCPROD1"):SetValue("Nº")
        //oProcPrd:Cell("PROCPROD2"):SetValue("Seq.")
        oProcPrd:Cell("PROCPROD2"):SetValue("Descrição")  
        oProcPrd:PrintLine()  
        fAjuFonte(oProcPrd,oFont12,"PROCPROD",2)
        oReport:SkipLine()
    endif

    if _lEstrut    
        fAjuFonte(oEstrut,oFont12N,"ESTRUT",7)
        oEstrut:Cell("ESTRUT1"):SetValue("Componente")
        oEstrut:Cell("ESTRUT2"):SetValue("Descrição")
        oEstrut:Cell("ESTRUT3"):SetValue("UN")
        oEstrut:Cell("ESTRUT4"):SetValue("Nº Lote")
        oEstrut:Cell("ESTRUT5"):SetValue("Lote Externo")
        oEstrut:Cell("ESTRUT6"):SetValue("Armazem")
        oEstrut:Cell("ESTRUT7"):SetValue("Qtde")
        oEstrut:PrintLine()
        fAjuFonte(oEstrut,oFont12,"ESTRUT",7)
        oReport:SkipLine() 
    endif   

    if _lRotOper
        fAjuFonte(oRotCbOpe,oFont12N,"ROTCBOPER",7)
        oRotCbOpe:Cell("ROTCBOPER1"):SetValue("Sequência") 
        oRotCbOpe:Cell("ROTCBOPER2"):SetValue("") 
        oRotCbOpe:Cell("ROTCBOPER3"):SetValue("Descrição")
        oRotCbOpe:Cell("ROTCBOPER4"):SetValue("Recurso")
        //oRotCbOpe:Cell("ROTCBOPER5"):SetValue("Qtd Oper.")
        oRotCbOpe:Cell("ROTCBOPER5"):SetValue("Desc")
        oRotCbOpe:Cell("ROTCBOPER7"):SetValue("Tempo Estim.")
        oRotCbOpe:PrintLine()
        oReport:SkipLine()
        fAjuFonte(oRotCbOpe,oFont12,"ROTCBOPER",7)
    endif 

   oReport:Say(3200, 0001, "*Consumo Chão de Fábrica", oFont08,,,, PAD_LEFT)
   oReport:Say(3200, nLimiteHor+200, "Página: " + StrZero(oReport:Page(), 4), oFont10N,,,, PAD_RIGHT)
   
Return nil

Static Function fQryOP(cQuery)
    cQuery := "SELECT SB1.*, "				         	+CRLF
	cQuery += "SC2.*, "      							+CRLF
	cQuery += "CASE "									+CRLF
	cQuery += "WHEN SC2.C2_ROTEIRO = '  ' THEN '01' "	+CRLF
	cQuery += "ELSE SC2.C2_ROTEIRO "					+CRLF
	cQuery += "END C2_ROTEIRO, "						+CRLF

    cQuery += "ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),B1_ZZEMBAL)),'') AS ESPEMB, "   +CRLF
    cQuery += "ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),B1_ZZTREMB)),'') AS TRATEMB " +CRLF

	cQuery += "FROM   " +RetSqlName("SC2")+ " SC2 "		+CRLF

	cQuery += "INNER JOIN " +RetSqlName("SB1")+ " SB1 "	+CRLF
	cQuery += "ON SB1.B1_COD = SC2.C2_PRODUTO "			+CRLF
	cQuery += "AND SB1.D_E_L_E_T_ = ' '   "	+CRLF

	cQuery += "WHERE  SC2.C2_FILIAL = '"+xFilial('SC2')+"' "													+CRLF
	cQuery += "AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN BETWEEN '" +_cOpIni+ "  ' AND '" +_cOpFim+ "  ' "	+CRLF
	cQuery += "AND SC2.C2_EMISSAO BETWEEN '" +DTOS(_dDtIni)+ "' AND '" +DTOS(_dDtFim)+ "' "						+CRLF
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' "																		+CRLF
	cQuery += "ORDER  BY SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN "
	
return Nil

Static Function TrazOpOrigem(_cOpOrigem)
    Local _cRet

    _cCqrySD4:="SELECT DISTINCT SD4.D4_OP AS OPORIG FROM "+RetSqlName("SD4")+" SD4 "
    _cCqrySD4+="WHERE SD4.D4_FILIAL='"+xFilial("SD4")+"' AND SD4.D4_OPORIG='"+_cOpOrigem+"' AND SD4.D_E_L_E_T_=' ' "

    if select("TD4ORIG") <>0
        TD4ORIG->(dBCloseArea())
    endif
    TCQUERY _cCqrySD4 NEW ALIAS "TD4ORIG"

    SC2->(dbsetorder(1))
    SC2->(dbseek(xFilial("SC2")+TD4ORIG->OPORIG))

    _cRet := SC2->C2_NUM+"/"+SC2->C2_ITEM+"/"+SC2->C2_SEQUEN+" - "+SC2->C2_PRODUTO+" - "+SC2->C2_ZZDESCP

    TD4ORIG->(dBCloseArea())

Return(_cRet)

Static Function fTrazEpi(_aEpi)
    Local _cEpiOP := alltrim(TCSC2->C2_ZZEPI)
    Local _cEpis
    Local _aEpiPad := {}
    Local _nIndex
    Local _nJ
    Local _cQuery
    
    _cQuery := "SELECT DISTINCT ZBA.ZBA_DESCRI FROM "+RetSqlname("ZBA")+" ZBA WHERE ZBA.ZBA_FILIAL='"+xFilial("ZBA")+"' AND ZBA.D_E_L_E_T_=' ' "

    if select("TZBA") <>0
        TZBA->(dBCloseArea())
    endif
    TCQUERY _cQuery NEW ALIAS "TZBA"
    TZBA->(dbgotop())
    
    _cEpis := ""

    do while TZBA->(!eof())

       if len(_cEpis) < len(alltrim(TZBA->ZBA_DESCRI))
          _cEpis := alltrim(TZBA->ZBA_DESCRI)
       endif   

       TZBA->(dbskip())
    enddo

    TZBA->(dBCloseArea())

    _aEpiPad := Separa(_cEpis,"/",.T.)

    _aEpi := Separa(_cEpiOP,"/",.T.)

    // *** Pesquisando os Epis da Op denrto dos Epis Padrés e colocando o X
    for _nIndex := 1 to len(_aEpi)
        _cEpi := alltrim(_aEpi[_nIndex])

        for _nJ := 1 to len(_aEpiPad) 
            if _cEpi $ _aEpiPad[_nJ]
                _aEpiPad[_nJ] := alltrim(_aEpiPad[_nJ])+" [ X ]"
            endif
        next
    next

      // Ajustando os Epis padrões
    for _nIndex := 1 to len(_aEpiPad)
        if  !([ X ] $ _aEpiPad[_nIndex] )
            _aEpiPad[_nIndex] := alltrim(_aEpiPad[_nIndex])+" [  ]"
        endif    
    next


    _aEpi := _aEpiPad

return nil

Static Function fQrCode(oReport, oRotCbOpe,_cLink,_cOper,_cOp)
    Local _cUrl
    Local _cstringqrcode := _cLink
    Local _nRet
    Local _cHtml
    Local _nLin
    Local _nCol
    Local _cDir := "C:\TEMP\"
    Local _cTime := substr(Time(),1,2)+substr(Time(),4,2)+substr(Time(),7,2)
    Local _cArqPng := alltrim(_cOp)+"_"+alltrim(_cOper)+"_"+_cTime+"__qrcode.png"

    if !empty(_cLink)

        _cUrl := "http://api.qrserver.com/v1/create-qr-code/?" 
        _cUrl += "color=000000&bgcolor=FFFFFF&data=" + _cstringqrcode + "&qzone=1&margin=0&size=400x400&ecc=L"
        //url := "http://api.qrserver.com/v1/create-qr-code/?" 
        //url += "color=000000&bgcolor=FFFFFF&data=" + _cstringqrcode + "&qzone=1&margin=0&size=400x400&ecc=L"

        if !ExistDir( "c:\temp" )
        _nRet := MakeDir("\temp", ,.T.)
        endif

        _cHtml := HttpGet( _cUrl ) 
        MemoWrite(_cDir+_cArqPng, _cHtml )

        _nLin := oReport:Row() - 50
        _nCol :=  oRotCbOpe:Cell("ROTCBOPER7"):ColPos()+120

        oReport:SayBitmap( _nLin ,_nCol,_cDir+_cArqPng,150,150 )
        Ferase(_cDir+_cArqPng)
        
    endif    
   
   oReport:SkipLine()
   oReport:SkipLine()
   oReport:SkipLine()

return nil

Static Function fCodBarras(oReport,_cCodOper)
    Local _nLinha

    _nLinha := oReport:Row() / 121
    
   //oQrCode := FwQrCode():New({20,20,150,150},@oReport:oPrint, "MIGUEL BERNARDO" )
   ////// oQrCode:SetCodeBar(cNewCod)
   //oQrCode:Refresh()
    
    MSBAR4("CODE128",_nLinha ,000   , _cCodOper ,@oReport:oPrint,NIL,NIL,NIL,3,0.7,.F.,NIL,"A",.F.)

return nil

Static Function fAjuFonte(oRotCbOpe,oFont,_cCell,_nQtd)
    Local _nIndex
    Local _cCelula

    for _nIndex := 1 to _nQtd
        _cCelula := _cCell+alltrim(str(_nIndex,0))
        oRotCbOpe:Cell(_cCelula):oFontBody := oFont
    next    

return nil


Static Function fProcPrd()
    Local _aRet := {}
    Local _nCont := 1
    Local _aMemo
    Local _nIndex

    TCG2->(dbgotop())

    do while TCG2->(!eof())

   
        aadd(_aRet,{TCG2->G2_OPERAC,"     ETAPA "+alltrim(str(_nCont))+": "+TCG2->G2_DESCRI})
        aadd(_aRet,{TCG2->G2_OPERAC,"INSTRUÇÔES"})

        if !empty(TCG2->G2MEMO)
           _aMemo := fMemoToA(TCG2->G2MEMO, 150, , .T.)

           for _nIndex := 1 to len(_aMemo)
                if !empty(_aMemo[_nIndex])
                    aadd(_aRet,{TCG2->G2_OPERAC,"     "+_aMemo[_nIndex]})
                endif     
           next    

        endif
        
        TCG2->(dbskip())
    enddo

Return(_aRet)    


/*/{Protheus.doc} fMemoToA
Função Memo To Array, que quebra um texto em um array conforme número de colunas
@author Atilio
@since 15/08/2014
@version 1.0
    @param cTexto, Caracter, Texto que será quebrado (campo MEMO)
    @param nMaxCol, Numérico, Coluna máxima permitida de caracteres por linha
    @param cQuebra, Caracter, Quebra adicional, forçando a quebra de linha além do enter (por exemplo '<br>')
    @param lTiraBra, Lógico, Define se em toda linha será retirado os espaços em branco (Alltrim)
    @return nMaxLin, Número de linhas do array
    @example
    cCampoMemo := SB1->B1_X_TST
    nCol        := 200
    aDados      := u_zMemoToA(cCampoMemo, nCol)
    @obs Difere da MemoLine(), pois já retorna um Array pronto para impressão
/*/
 
Static Function fMemoToA(cTexto, nMaxCol, cQuebra, lTiraBra)
    Local aArea     := GetArea()
    Local aTexto    := {}
    Local aAux      := {}
    Local nAtu      := 0
    Default cTexto  := ''
    Default nMaxCol := 80
    Default cQuebra := ';'
    Default lTiraBra:= .T.
 
    //Quebrando o Array, conforme -Enter-
    aAux:= StrTokArr(cTexto,Chr(13))
     
    //Correndo o Array e retirando o tabulamento
    For nAtu:=1 TO Len(aAux)
        aAux[nAtu]:=StrTran(aAux[nAtu],Chr(10),'')
    Next
     
    //Correndo as linhas quebradas
    For nAtu:=1 To Len(aAux)
     
        //Se o tamanho de Texto, for maior que o número de colunas
        If (Len(aAux[nAtu]) > nMaxCol)
         
            //Enquanto o Tamanho for Maior
            While (Len(aAux[nAtu]) > nMaxCol)
                //Pegando a quebra conforme texto por parâmetro
                nUltPos:=RAt(cQuebra,SubStr(aAux[nAtu],1,nMaxCol))
                 
                //Caso não tenha, a última posição será o último espaço em branco encontrado
                If nUltPos == 0
                    nUltPos:=Rat(' ',SubStr(aAux[nAtu],1,nMaxCol))
                EndIf
                 
                //Se não encontrar espaço em branco, a última posição será a coluna máxima
                If(nUltPos==0)
                    nUltPos:=nMaxCol
                EndIf
                 
                //Adicionando Parte da Sring (de 1 até a Úlima posição válida)
                aAdd(aTexto,SubStr(aAux[nAtu],1,nUltPos))
                 
                //Quebrando o resto da String
                aAux[nAtu] := SubStr(aAux[nAtu], nUltPos+1, Len(aAux[nAtu]))
            EndDo
             
            //Adicionando o que sobrou
            aAdd(aTexto,aAux[nAtu])
        Else
            //Se for menor que o Máximo de colunas, adiciona o texto
            aAdd(aTexto,aAux[nAtu])
        EndIf
    Next
     
    //Se for para tirar os brancos
    If lTiraBra
        //Percorrendo as linhas do texto e aplica o AllTrim
        For nAtu:=1 To Len(aTexto)
            aTexto[nAtu] := Alltrim(aTexto[nAtu])
        Next
    EndIf
     
    RestArea(aArea)
Return aTexto


Static function fBarra(oReport,_lEtapa,_lPri,oProcPrd,_lPri)
    //Local _nCols 
    //Local _nIndex
    Local _nColIni
    Local _nLinIni
    //Local _lImp

    if !_lPri
        oReport:ThinLine()
        oReport:SkipLine()
    endif
    oReport:SkipLine()
    _nLinIni := oReport:Row()-35

    if _lEtapa

        _nColIni := 1200
        _nColFim := _nColIni+300
        oReport:Box( _nLinIni , _nColIni , _nLinIni+155 , _nColFim)
        oReport:Say(_nLinIni+20, _nColIni+100, "Data" , oFont12N,,,,)
    
        _nColIni := _nColFim
        _nColFim := _nColIni+300
        oReport:Box( _nLinIni , _nColIni , _nLinIni+155 , _nColFim)
        oReport:Say(_nLinIni+20, _nColIni+100, "Início" , oFont12N,,,,)

        _nColIni := _nColFim
        _nColFim := _nColIni+300
        oReport:Box( _nLinIni , _nColIni , _nLinIni+155 , _nColFim)
        oReport:Say(_nLinIni+20, _nColIni+100, "Data" , oFont12N,,,,)
    
        _nColIni := _nColFim
        _nColFim := _nColIni+300
        oReport:Box( _nLinIni , _nColIni , _nLinIni+155 , _nColFim)    
        oReport:Say(_nLinIni+20, _nColIni+100, "Fim" , oFont12N,,,,)    
    endif  
   oReport:Box(_nLinIni+155 , 0000 , _nLinIni+155 , _nColFim)  
   oReport:SkipLine()
   oReport:SkipLine()

   

/*

    for _nIndex :=  1  to 3
        if _nIndex <= 3 
           _nCols := 0
        else   
         _nCols := 220 
        endif   

        _nColIni := oProcPrd:Cell("PROCPROD"+alltrim(str(_nIndex))):ColPos()+_nCols
        //oReport:Box( _nLinIni , _nColIni , _nLinIni+iif(_lUlt,110,160) , _nColIni)
        oReport:Box( _nLinIni-13 , _nColIni , _nLinIni+110 , _nColIni)

    next

  */   

return nil 


Static Function fEspFinal(_cCodProd,_cEspFinal,_cAmostra)
    Local _cQryEsp

   // _cEspFinal := ""
    _cAmostra  := ""

    _cQryEsp:="SELECT "	+CRLF
    _cQryEsp+="QP7.QP7_ENSAIO AS CODENSAIO, "	+CRLF
    _cQryEsp+="QP7.QP7_LABOR AS LABOR, "	+CRLF
    _cQryEsp+="QP7.QP7_SEQLAB AS SEQLAB, "	+CRLF
    _cQryEsp+="QP7.QP7_NOMINA AS NOMINA, "	+CRLF
    _cQryEsp+="QP7.QP7_LIE AS LIE, "	+CRLF
    _cQryEsp+="QP7.QP7_LSE AS LSE, "	+CRLF
    _cQryEsp+="'' AS TEXTO, "	+CRLF
    _cQryEsp+="QP1.QP1_DESCPO AS ENSAIO, "	+CRLF
    _cQryEsp+="ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),QP6.QP6_ZZCQOP)),'') AS CQOP, "	+CRLF
    _cQryEsp+="ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),QP6.QP6_ZZESOR)),'') AS ESPORI, "   +CRLF
    _cQryEsp+="SAH.AH_UMRES AS UNDESC "	+CRLF
    _cQryEsp+="FROM "+RetSqlName("QP6")+" QP6 "	+CRLF
    _cQryEsp+="INNER JOIN "+RetSqlName("QP7")+" QP7 ON (QP7.QP7_FILIAL='"+xFilial("QP7")+"' AND QP7.QP7_CODREC=QP6.QP6_CODREC AND  QP7.QP7_REVI=QP6.QP6_REVI AND     QP7.QP7_PRODUT = QP6.QP6_PRODUT AND QP7.D_E_L_E_T_=' ') "	+CRLF
    _cQryEsp+="INNER JOIN "+RetSqlName("QP1")+" QP1 ON (QP1.QP1_FILIAL='"+xFilial("QP1")+"' AND QP1.QP1_ENSAIO=QP7.QP7_ENSAIO AND QP1.D_E_L_E_T_=' ') "	+CRLF
    _cQryEsp+="LEFT JOIN "+RetSqlName("SAH")+"  SAH ON (SAH.AH_FILIAL='"+xFilial("SAH")+"' AND SAH.AH_UNIMED=QP7.QP7_UNIMED AND SAH.D_E_L_E_T_=' ') "+CRLF
    _cQryEsp+="WHERE QP6.QP6_FILIAL='"+xFilial("QP6")+"' AND QP6.QP6_PRODUT='"+_cCodProd+"' AND QP6.D_E_L_E_T_=' '  AND  QP6.QP6_SITREV IN ('0') "	+CRLF
    
    _cQryEsp+=" UNION ALL "	+CRLF

    _cQryEsp+="SELECT "	+CRLF
    _cQryEsp+="QP8.QP8_ENSAIO AS CODENSAIO, "	+CRLF
    _cQryEsp+="QP8.QP8_LABOR AS LABOR, "	+CRLF
    _cQryEsp+="QP8.QP8_SEQLAB AS SEQLAB, "	+CRLF
    _cQryEsp+="'' AS NOMINA, "	+CRLF
    _cQryEsp+="'' AS LIE, "	+CRLF
    _cQryEsp+="'' AS LSE, "	+CRLF
    _cQryEsp+="QP8.QP8_TEXTO AS TEXTO, "	+CRLF
    _cQryEsp+="QP1.QP1_DESCPO AS ENSAIO, "	+CRLF
    _cQryEsp+="ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),QP6.QP6_ZZCQOP)),'') AS CQOP, "	+CRLF
    _cQryEsp += "ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),QP6.QP6_ZZESOR)),'') AS ESPORI, "   +CRLF    
    _cQryEsp+=" '' AS UNDESC "	+CRLF
    _cQryEsp+="FROM "+RetSqlName("QP6")+" QP6 "	+CRLF
    _cQryEsp+="INNER JOIN "+RetSqlName("QP8")+" QP8 ON (QP8.QP8_FILIAL='"+xFilial("QP8")+"' AND QP8.QP8_CODREC=QP6.QP6_CODREC AND  QP8.QP8_REVI=QP6.QP6_REVI AND   QP8.QP8_PRODUT = QP6.QP6_PRODUT AND QP8.D_E_L_E_T_=' ') "	+CRLF
    _cQryEsp+="INNER JOIN "+RetSqlName("QP1")+" QP1 ON (QP1.QP1_FILIAL='"+xFilial("QP1")+"' AND QP1.QP1_ENSAIO=QP8.QP8_ENSAIO AND QP1.D_E_L_E_T_=' ') "	+CRLF
    _cQryEsp+="WHERE QP6.QP6_FILIAL='"+xFilial("QP6")+"' AND QP6.QP6_PRODUT='"+_cCodProd+"' AND QP6.D_E_L_E_T_=' '  AND  QP6.QP6_SITREV IN ('0') "	+CRLF
   
   
    _cQryEsp+="ORDER BY QP7.QP7_SEQLAB "+CRLF
   
    if select("TESPFINAL") <>0
        TESPFINAL->(dBCloseArea())
    endif
    TCQUERY _cQryEsp NEW ALIAS "TESPFINAL"

    TESPFINAL->(dbgotop())

    _cAmostra := TESPFINAL->CQOP
/*    
    do while TESPFINAL->(!eof())
        _cEspFinal+=iif(empty(_cEspFinal), alltrim(TESPFINAL->QP1_DESCPO),", "+alltrim(TESPFINAL->QP1_DESCPO) )
        TESPFINAL->(dbskip())
    enddo
    

    TESPFINAL->(dBCloseArea())

  */  
    

return nil


Static Function fBoxFinal(oReport,oCabec,oProcPrd,oEstrut,oRotCbOpe)
    Local _nLinAtu 
    Local _nIndex
    
    if oReport:Row() > _nLinFinal
        oReport:EndPage()
        ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe)
    endif
   
    oReport:SkipLine()
    _nLinAtu := oReport:Row()

    for _nIndex := 1 to 10

        if _nLinAtu > _nLinFinal
            oReport:EndPage()
            ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe) 
            _nLinAtu := oReport:Row()
        endif

        oReport:Box( _nLinAtu , 0000 , _nLinAtu+150 , oReport:PageWidth() ) 
        _nLinAtu+=150

    next     

return nil
/* ----------------------------------------------------------------------- */
Static Function fFinalPage(oReport,oCabec,oProcPrd,oEstrut,oRotCbOpe)
    Local _nLinAtu 
    Local _nIndex

    //if oReport:Row() > _nLinFinal
    oReport:EndPage()
    ImpCab(oReport,.F.,oCabec,.F.,oProcPrd,.F.,oEstrut,.F.,oRotCbOpe) 
    //endif
   
  //  oReport:Say( oReport:Row(), 001, "O_nLinAtu+130BERVAÇÕES GERAIS", oFont12N,,,,)
    oReport:SkipLine()
    _nLinAtu := oReport:Row()

    oReport:Box( _nLinAtu       , 0000                      , _nLinAtu + 70 , oReport:PageWidth() )
    oReport:Say( _nLinAtu + 25  , (oReport:PageWidth() / 2) - 200  , "ITENS REQUISITADOS", oFont12N,,,,)
    
    _nLinAtu += 70
    oReport:Box( _nLinAtu       , 0000  , _nLinAtu + 70 , 300  )
    oReport:Box( _nLinAtu       , 300   , _nLinAtu + 70 , 1600 )
    oReport:Box( _nLinAtu       , 1600  , _nLinAtu + 70 , 2000 )
    oReport:Box( _nLinAtu       , 2000  , _nLinAtu + 70 , oReport:PageWidth() )

    oReport:Say( _nLinAtu + 25  , 70    , "CÓDIGO"      , oFont12N,,,,)
    oReport:Say( _nLinAtu + 25  , 850   , "DESCRIÇÃO"   , oFont12N,,,,)
    oReport:Say( _nLinAtu + 25  , 1700  , "QUANTIDADE"  , oFont12N,,,,)
    oReport:Say( _nLinAtu + 25  , 2150  , "LOTE"        , oFont12N,,,,)

    //oReport:SkipLine()
    //_nLinAtu += 70

    for _nIndex := 1 to 22
        _nLinAtu+=70
        oReport:Box( _nLinAtu       , 0000  , _nLinAtu + 70 , 300  )
        oReport:Box( _nLinAtu       , 300   , _nLinAtu + 70 , 1600 )
        oReport:Box( _nLinAtu       , 1600  , _nLinAtu + 70 , 2000 )
        oReport:Box( _nLinAtu       , 2000  , _nLinAtu + 70 , oReport:PageWidth() )
    next     
    
    _nLinAtu+=100
    
    oReport:Box( _nLinAtu       , 0000                              , _nLinAtu + 80 , oReport:PageWidth() )
    oReport:Say( _nLinAtu + 25  , (oReport:PageWidth() / 2) - 200   , "INFORMAÇÕES DE CORREÇÃO", oFont12N,,,,)

    for _nIndex := 1 to 8
        _nLinAtu+=80
        oReport:Box( _nLinAtu       , 0000  , _nLinAtu + 80 , oReport:PageWidth() )
    next


return nil
