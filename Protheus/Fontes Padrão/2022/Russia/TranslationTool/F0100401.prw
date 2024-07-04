#INCLUDE "PROTHEUS.CH"

User Function F0100401()
    
    InitProc()

    MakeDoc1()
    MakeDoc2()
    MakeDoc3()
    MakeDoc5()
    MakeDoc6()
    MakeDocA()
    MakeDocB()
    MakeDocG()
    MakeDocH()
    MakeDocM()
    MakeDocS()

    ClearProc()

Return

Static Function InitProc()

    Local aConfig    := StrTokArr(GetNewPar("FS_SMACAT1", "000000|en|ru"), "|")
    Local cIdiomFrom := aConfig[2]

    Static cIdiomBkp := ""
    
    cIdiomBkp := FwRetIdiom()

    FwSetIdiom(cIdiomFrom)

Return

Static Function ClearProc()

    FwSetIdiom(cIdiomBkp)
    
    cIdiomBkp := Nil

Return

/*/{Protheus.doc} MakeDoc1()
Cria os Documentos formato ResX para a origem '1'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDoc1()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local aStringsRu  := {}
    Local cFile     := ""

    BeginSQL Alias cAliasZA1
         SELECT ZA1.ZA1_KEY1   GRUPO ,
                ZA1.R_E_C_N_O_ ZA1REC,
                (CASE ZA1_KEY4
                    WHEN "X1_PERGUNT" THEN 1
                    ELSE 2
                END) FIELDORDER
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = '1'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = '1'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.ZA1_KEY1   = ZA1.ZA1_KEY1
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY ZA1_KEY1, ZA1_KEY3, FIELDORDER, ZA1_KEY4
    EndSQL

    While (cAliasZA1)->(!EoF())
        
        cFile    := (cAliasZA1)->GRUPO
        aStrings := {}

        While (cAliasZA1)->(!EoF()) .And. cFile == (cAliasZA1)->GRUPO
            ZA1->(DbGoTo((cAliasZA1)->ZA1REC))
            
            ContextSX1(aStrings)

            cIdiomBkp := FwRetIdiom()
            FwSetIdiom('ru')
            ContextSX1(@aStringsRu)
            FwSetIdiom(cIdiomBkp)

            (cAliasZA1)->(DbSkip())
        End
        //Verify if there is something to be translated        
        If StrNotTrans(aStringsRu)
            FwResX(aStrings, Lower(cPath), "SX1_" + cFile)
            UpdZA1Status(aStrings)
        Else    
//          UpdZA1Status(aStrings,'Not send: Nothing to translate')
        Endif    
    End

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSX1(aStrings)

    Local aComment := {}
    Local cGrupo   := RTrim(ZA1->ZA1_KEY1)
    Local cOrdem   := RTrim(ZA1->ZA1_KEY3)
    Local cField   := RTrim(ZA1->ZA1_KEY4)
    Local cValue   := ""
    Local cName    := ""
    Local cHelp    := ""

    SX1->(DbSetOrder(1))
    SX1->(DbSeek(PadR(cGrupo, Len(SX1->X1_GRUPO)) + cOrdem  ))

    cName  := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))
    
    If cField == 'X1_PERGUNT'

        cValue := RTrim(X1Pergunt())
        aComment := {"Question parameter",;
                     "Size limit: " + CValToChar(Len(SX1->X1_PERGUNT)),;
                     "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}

        cHelp := RTrim(Ap5GetHelp("." + cGrupo + cOrdem + "."))

        If !Empty(cHelp)
            AAdd(aComment, "Help for question : " + cHelp)
        EndIf

    Else
        Do Case
            Case cField =='X1_DEF01'
                cValue := RTrim(X1Def01())
            Case cField =='X1_DEF02'
                cValue := RTrim(X1Def02())
            Case cField =='X1_DEF03'
                cValue := RTrim(X1Def03())
            Case cField =='X1_DEF04'
                cValue := RTrim(X1Def04())
            Case cField =='X1_DEF05'
                cValue := RTrim(X1Def05())
        EndCase

        aComment := {"Question parameter option for question : " + X1Pergunt(),;
                     "Size limit: " + CValToChar(Len(SX1->X1_DEF01)),;
                     "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}
    EndIf

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

    If !Empty(cHelp) .And. cField == 'X1_PERGUNT' // Adiciona o Help do campo para ser traduzido
        aComment := {"Question parameter help for question : " + X1Pergunt()}
        cName    := ZA1->ZA1_IDIOM + "H" + "." + cGrupo + cOrdem + "."
        cValue   := cHelp
        AAdd(aStrings, {U_GetZA1Rec(cName), cName, cValue, aComment})
    EndIf

Return

/*/{Protheus.doc} MakeDoc2()
Cria os Documentos formato ResX para a origem '2'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDoc2()

    Local cAliasZA1     := GetNextAlias()
    Local cPath         := GetNewPar("FS_DOCINP", "input")
    Local aStrings      := {}
    Local aStringsRu    := {}
    Local cFile         := "SX2"

    BeginSQL Alias cAliasZA1
         SELECT ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = '2'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = '2'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY ZA1_KEY1
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        ContextSX2(aStrings)
        cIdiomBkp := FwRetIdiom()
        FwSetIdiom('ru')
        ContextSX2(@aStringsRu)
        FwSetIdiom(cIdiomBkp)

        (cAliasZA1)->(DbSkip())
    End
        //Verify if there is something to be translated        
    If StrNotTrans(aStringsRu)
        FwResX(aStrings, Lower(cPath), cFile)
        UpdZA1Status(aStrings)
    Endif
    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSX2(aStrings)

    Local aComment := {}
    Local cChave   := RTrim(ZA1->ZA1_KEY1)
    Local cValue   := ""
    Local cName    := ""

    SX2->(DbSetOrder(1))
    SX2->(MsSeek(cChave))

    aComment := {"Table name",;
                 "Size limit: " + CValToChar(Len(SX2->X2_NOME)),;
                 "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}


    cValue   := RTrim(X2Nome())
    cName    := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

/*/{Protheus.doc} MakeDoc3()
Cria os Documentos formato ResX para a origem '3'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDoc3()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local aStringsRu    := {}

    BeginSQL Alias cAliasZA1
         SELECT ZA1.ZA1_KEY1   CAMPO , 
                ZA1.R_E_C_N_O_ ZA1REC,
                (CASE ZA1_KEY2
                    WHEN 'X3_TITULO'  THEN 1
                    WHEN 'X3_DESCRIC' THEN 2
                    WHEN 'X3_CBOX'    THEN 3
                    ELSE 4
                END) FIELDORDER
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = '3'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = '3'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            //TODO POSTGRES:SubStr(ZA1.ZA1_KEY1,1, StrPos (ZA1.ZA1_KEY1,'_'))||'%'
                              AND NEW.ZA1_KEY1 LIKE SubStr(ZA1.ZA1_KEY1,1, StrPos (ZA1.ZA1_KEY1,'_'))||'%'                                  
                            //AND NEW.ZA1_KEY1 LIKE SubString(ZA1.ZA1_KEY1, 1, CHARINDEX ('_', ZA1.ZA1_KEY1))+'%'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY CAMPO, FIELDORDER
    EndSQL

    While (cAliasZA1)->(!EoF())
        
        cFile    := SubStr((cAliasZA1)->CAMPO, 1, At("_", (cAliasZA1)->CAMPO))
        aStrings := {}

        While (cAliasZA1)->(!EoF()) .And. cFile == SubStr((cAliasZA1)->CAMPO, 1, At("_", (cAliasZA1)->CAMPO))
            ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

            ContextSX3(aStrings)
            cIdiomBkp := FwRetIdiom()
            FwSetIdiom('ru')
            ContextSX3(@aStringsRu)
            FwSetIdiom(cIdiomBkp)


            (cAliasZA1)->(DbSkip())
        End
        If StrNotTrans(aStringsRu)
            FwResX(aStrings, Lower(cPath), "SX3_" + cFile)
            UpdZA1Status(aStrings)
        Endif

    End

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSX3(aStrings)

    Local aComment := {}
    Local cCampo   := RTrim(ZA1->ZA1_KEY1)
    Local cAttrib  := RTrim(ZA1->ZA1_KEY2)
    Local cValue   := ""
    Local cName    := ""
    Local cHelp    := ""

   	SX3->(DbSetOrder(2))
    SX3->(MsSeek(cCampo))
    SX2->(DbSetOrder(1))
    SX2->(MsSeek(SX3->X3_ARQUIVO))

    cHelp := RTrim(Ap5GetHelp(cCampo))

    If cAttrib == 'X3_TITULO'
        If !Empty(cHelp)
            cName    := RTrim(ZA1->ZA1_IDIOM + "H" + cCampo)
            cValue   := cHelp
            aComment := {"Help for field: " + cCampo}
            AAdd(aStrings, {U_GetZA1Rec(cName), cName, cValue, aComment})
        EndIf

        cValue := AllTrim(X3Titulo())
        aComment := {"Title for field '" + cCampo + "' from table '" + X2Nome() + "'",;
                     "Size limit: " + CValToChar(Len(SX3->X3_TITULO))}
    ElseIf cAttrib == 'X3_DESCRIC'
        cValue := AllTrim(X3Descric())
        aComment := {"Description for field '" + cCampo + "' from table '" + X2Nome() + "'",;
                     "Size limit: " + CValToChar(Len(SX3->X3_DESCRIC))}
    Else
        cValue := AllTrim(X3CBox())
        aComment := {"Options for field '" + cCampo + "' from table '" + X2Nome() + "'",;
                     "DONT CHANGE EXPRESSION BEFORE = SIGN. Y = Yes should be translated as Y =Äà",;
                     "Size limit: " + CValToChar(Len(SX3->X3_CBOX))}
    EndIf

    If !Empty(cHelp)
        AAdd(aComment, "Field HELP: " + cHelp)
    EndIf
   
    AAdd(aComment, "Current Translation: " + RTrim(ZA1->ZA1_TEXT))

    cName := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

/*/{Protheus.doc} MakeDoc5()
Cria os Documentos formato ResX para a origem '5'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDoc5()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := "SX5"
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.R_E_C_N_O_ ZA1REC,
                (CASE ZA1_KEY1
                    WHEN '00' THEN ZA1_KEY2
                    ELSE ZA1_KEY1
                END) FIELDORDER
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = '5'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = '5'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY FIELDORDER
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        ContextSX5(aStrings)

        cIdiomBkp := FwRetIdiom()
        FwSetIdiom('ru')
        ContextSX5(@aStringsRu)
        FwSetIdiom(cIdiomBkp)

        (cAliasZA1)->(DbSkip())
    End

    If StrNotTrans(aStringsRu)
        FwResX(aStrings, Lower(cPath), cFile)
        UpdZA1Status(aStrings)
    Endif

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSX5(aStrings)

    Local aComment := {}
    Local cTabela  := RTrim(ZA1->ZA1_KEY1)
    Local cChave   := RTrim(ZA1->ZA1_KEY2)
    Local cValue   := ""
    Local cName    := ""

    SX5->(DbSetOrder(1))
    SX5->(DbSeek(XFilial() + cTabela + cChave))

    cValue   := RTrim(X5Descri())
    cName    := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))

    If cTabela == "00" // cabeçalho
        aComment := {"Table names",;
                     "Size limit: " + CValToChar(Len(SX5->X5_DESCRI))}
    Else
        SX5->(MsSeek(XFilial() +"00" + cTabela)) // posiciona no cabeçalho
        aComment := {"Item from table '" + RTrim(X5Descri()) + "'",;
                     "Size limit: " + CValToChar(Len(SX5->X5_DESCRI))}
    EndIf

    AAdd(aComment, "Current Translation: " + RTrim(ZA1->ZA1_TEXT))

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

/*/{Protheus.doc} MakeDoc6()
Cria os Documentos formato ResX para a origem '6'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDoc6()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := "SX6"
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = '6'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_KEY2   = 'X6_DESCRIC'
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = '6'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        ContextSX6(aStrings)
        cIdiomBkp := FwRetIdiom()
        FwSetIdiom('ru')
        ContextSX6(@aStringsRu)
        FwSetIdiom(cIdiomBkp)

        (cAliasZA1)->(DbSkip())
    End

    If StrNotTrans(aStringsRu)
        FwResX(aStrings, Lower(cPath), cFile)
        UpdZA1Status(aStrings)
    Endif

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSX6(aStrings)

    Local aComment := {}
    Local cVar     := RTrim(ZA1->ZA1_KEY1)
    Local cValue   := ""
    Local cName    := ""
    Local nZA1Rec  := 0 

    SX6->(DbSetOrder(1))
    SX6->(DbSeek(XFilial() + cVar))

    cName  := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))
    cValue := RTrim(X6Descric())
    aComment := { cVar + " - parameter description",;
                 "Size limit: " + CValToChar(Len(SX6->X6_DESCRIC))}

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

    cValue := RTrim(X6Desc1())
    If !Empty(cValue)
        cName  := StrTran(cName, "X6_DESCRIC", "X6_DESC1")
        nZA1Rec := U_GetZA1Rec(cName)
        ZA1->(DbGoTo(nZA1Rec))
        aComment := {cVar + " - further parameter description (part 2)",;
                     "Size limit: " + CValToChar(Len(SX6->X6_DESC1))   ,;
                     "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}
        AAdd(aStrings, {nZA1Rec, cName, cValue, aComment})
    EndIf

    cValue := RTrim(X6Desc2())
    If !Empty(cValue)
        cName  := StrTran(cName, "X6_DESC1", "X6_DESC2")
        nZA1Rec := U_GetZA1Rec(cName)
        ZA1->(DbGoTo(nZA1Rec))
        aComment := {cVar + " - further parameter description (part 3)",;
                     "Size limit: " + CValToChar(Len(SX6->X6_DESC2))   ,;
                     "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}
        AAdd(aStrings, {nZA1Rec, cName, cValue, aComment})
    EndIf

Return

/*/{Protheus.doc} MakeDocA()
Cria os Documentos formato ResX para a origem 'A'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDocA()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := "SXA"
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = 'A'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = 'A'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY ZA1_KEY1, ZA1_KEY2, ZA1_KEY3
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        ContextSXA(aStrings)
        cIdiomBkp := FwRetIdiom()
        FwSetIdiom('ru')
        ContextSXA(@aStringsRu)
        FwSetIdiom(cIdiomBkp)

        (cAliasZA1)->(DbSkip())
    End

    If StrNotTrans(aStringsRu)
        FwResX(aStrings, Lower(cPath), cFile)
        UpdZA1Status(aStrings)
    Endif

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSXA(aStrings)

    Local aComment := {}
    Local cTabela  := RTrim(ZA1->ZA1_KEY1)
    Local cOrdem   := RTrim(ZA1->ZA1_KEY3)
    Local cValue   := ""
    Local cName    := ""

    SX2->(DbSetOrder(1))
    SX2->(DbSeek(cTabela))

    SXA->(DbSetOrder(1))
    SXA->(DbSeek(cTabela + cOrdem))

    aComment := {"Folders for table name '" + RTrim(X2Nome()) + "' (" + cTabela + ")",;
                 "Size limit: " + CValToChar(Len(SXA->XA_DESCRIC)),;
                 "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}

    cValue   := RTrim(XADescric())
    cName    := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

/*/{Protheus.doc} MakeDocB()
Cria os Documentos formato ResX para a origem 'B'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDocB()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := "SXB"
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = 'B'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = 'B'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY ZA1_KEY1, ZA1_KEY2, ZA1_KEY3, ZA1_KEY4
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        ContextSXB(aStrings)
        cIdiomBkp := FwRetIdiom()
        FwSetIdiom('ru')
        ContextSXB(@aStringsRu)
        FwSetIdiom(cIdiomBkp)

        (cAliasZA1)->(DbSkip())
    End

    If StrNotTrans(aStringsRu)
        FwResX(aStrings, Lower(cPath), cFile)
        UpdZA1Status(aStrings)
    Endif

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSXB(aStrings)

    Local aComment := {}
    Local cAlias   := PadR(RTrim(ZA1->ZA1_KEY1), Len(SXB->XB_ALIAS ))
    Local cTipo    := PadR(RTrim(ZA1->ZA1_KEY2), Len(SXB->XB_TIPO  ))
    Local cSeq     := PadR(RTrim(ZA1->ZA1_KEY3), Len(SXB->XB_SEQ   ))
    Local cColuna  := PadR(RTrim(ZA1->ZA1_KEY4), Len(SXB->XB_COLUNA))
    Local cValue   := ""
    Local cName    := ""

    SXB->(DbSetOrder(1))
    SXB->(DbSeek(cAlias + cTipo + cSeq + cColuna))

    aComment := {"File Query",;
                 "Size limit: " + CValToChar(Len(SXB->XB_DESCRI)),;
                 "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}

    cValue   := RTrim(XBDescri())
    cName    := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

/*/{Protheus.doc} MakeDocG()
Cria os Documentos formato ResX para a origem 'G'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDocG()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := "SXG"
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = 'G'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = 'G'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY ZA1_KEY1
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        ContextSXG(aStrings)
        cIdiomBkp := FwRetIdiom()
        FwSetIdiom('ru')
        ContextSXG(@aStringsRu)
        FwSetIdiom(cIdiomBkp)

        (cAliasZA1)->(DbSkip())
    End

    If StrNotTrans(aStringsRu)
        FwResX(aStrings, Lower(cPath), cFile)
        UpdZA1Status(aStrings)
    Endif

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSXG(aStrings)

    Local aComment := {}
    Local cGrupo   := RTrim(ZA1->ZA1_KEY1)
    Local cValue   := ""
    Local cName    := ""

    SXG->(DbSetOrder(1))
    SXG->(DbSeek(cGrupo))

    aComment := {"Field Group",;
                 "Size limit: " + CValToChar(Len(SXG->XG_DESCRI)),;
                 "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}

    cValue   := RTrim(XGDescri())
    cName    := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

/*/{Protheus.doc} MakeDocH()
Cria os Documentos formato ResX para a origem 'H'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDocH()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := "help"
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = 'H'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_KEY1 NOT LIKE 'P.%'
            AND ZA1_KEY1 NOT LIKE 'S.%'
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = 'H'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY ZA1_KEY1
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        ContextSXH(aStrings)
        cIdiomBkp := FwRetIdiom()
        FwSetIdiom('ru')
        ContextSXH(@aStringsRu)
        FwSetIdiom(cIdiomBkp)

        (cAliasZA1)->(DbSkip())
    End

    If StrNotTrans(aStringsRu)
        FwResX(aStrings, Lower(cPath), cFile)
        UpdZA1Status(aStrings)
    Endif

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextSXH(aStrings)

    Local aComment := {}
    Local cHelp    := RTrim(ZA1->ZA1_KEY1)
    Local cAttrib  := RTrim(ZA1->ZA1_KEY2)
    Local cValue   := ""
    Local cName    := ""

    IF !SX3->(DbSeek(RTrim(ZA1->ZA1_KEY1)))
        aComment := {"System Help",;
                     "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}
        cValue   := RTrim(FwFlavHelp("", ZA1->ZA1_IDIOM, cHelp, cAttrib))
        cName    := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))

        AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})
    EndIf

Return

/*/{Protheus.doc} MakeDocM()
Cria os Documentos formato ResX para a origem 'M'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDocM()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := ""
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.ZA1_MODULO MODULO,
                ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = 'M'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = 'M'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.ZA1_MODULO = ZA1.ZA1_MODULO
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
          ORDER BY MODULO, ZA1_KEY1, ZA1_KEY2
    EndSQL


    While (cAliasZA1)->(!EoF())

        cFile    := (cAliasZA1)->MODULO
        aStrings := {}
     
        While (cAliasZA1)->(!EoF()) .And. cFile == (cAliasZA1)->MODULO
            ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

            ContextM(aStrings)
            cIdiomBkp := FwRetIdiom()
            FwSetIdiom('ru')
            ContextM(@aStringsRu)
            FwSetIdiom(cIdiomBkp)

            (cAliasZA1)->(DbSkip())
        End

        If StrNotTrans(aStringsRu)
            FwResX(aStrings, Lower(cPath), "MENU_" + cFile)
            UpdZA1Status(aStrings)
        Endif

    End
//    UpdZA1Status(aStrings)

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextM(aStrings)

    Local aComment := {}
    Local cCodigo  := RTrim(ZA1->ZA1_KEY1)
    Local cAttrib  := RTrim(ZA1->ZA1_KEY2)
    Local cName    := ""
    Local cValue   := ""
   
    cName  := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))
    cValue := FwFlavMenu("", ZA1->ZA1_IDIOM, cAttrib, cCodigo)
    
    aComment := {"Menu item ",;
                 "Suggested Size Limit: " + CValToChar(Len(cValue)),;
                 "Current Translation: " + RTrim(ZA1->ZA1_TEXT)}

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

/*/{Protheus.doc} MakeDocS()    
Cria os Documentos formato ResX para a origem 'S'.
@author izac.ciszevski
@since 03/08/2017
/*/
Static Function MakeDocS()

    Local cAliasZA1 := GetNextAlias()
    Local cPath     := GetNewPar("FS_DOCINP", "input")
    Local aStrings  := {}
    Local cFile     := "source"
    Local aStringsRu    := {}
    
    BeginSQL Alias cAliasZA1
         SELECT ZA1.ZA1_KEY1   PROGRAMA,
                ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = 'S'
            AND ZA1_IDIOM  = %Exp:IdiomTo()%
            AND ZA1_STATUS = '1'
            AND ZA1_FLAV = 'TRANSL'
            AND EXISTS ( SELECT NEW.ZA1_KEY1
                           FROM %Table:ZA1% NEW
                          WHERE NEW.ZA1_ORIGIN = 'S'
                            AND NEW.ZA1_STATUS = '1'
                            AND NEW.ZA1_FLAV = 'TRANSL'
                            AND NEW.ZA1_KEY1   = ZA1.ZA1_KEY1
                            AND NEW.%NotDel%)
            AND ZA1.%NotDel%
        ORDER BY ZA1_KEY1, ZA1_KEY2
    EndSQL

    While (cAliasZA1)->(!EoF())
        
        cFile    := (cAliasZA1)->PROGRAMA
        aStrings := {}
     
        While (cAliasZA1)->(!EoF()) .And. cFile == (cAliasZA1)->PROGRAMA
            ZA1->(DbGoTo((cAliasZA1)->ZA1REC))
            
            ContextS(aStrings)
            cIdiomBkp := FwRetIdiom()
            FwSetIdiom('ru')
            ContextS(@aStringsRu)
            FwSetIdiom(cIdiomBkp)

            (cAliasZA1)->(DbSkip())
        End
        
        If StrNotTrans(aStringsRu)
            FwResX(aStrings, Lower(cPath), "SOURCE_" + cFile)
            UpdZA1Status(aStrings)
        Endif

    End

    (cAliasZA1)->(DbCloseArea())

Return

Static Function ContextS(aStrings)

    Local aComment := {}
    Local aIdiom   := {}
    Local cIdiom   := ""
    Local cSource  := RTrim(ZA1->ZA1_KEY1)
    Local cChave   := RTrim(ZA1->ZA1_KEY2)
    Local cName    := ""
    Local cValue   := ""
    Local nIdiom   := 0
    Local nSize    := 0

    cIdiom := FwRetIdiom()
    aIdiom := {'ru   ', 'es   ', 'en   ', 'pt-br'}

    For nIdiom := 1 To Len(aIdiom)
        FwSetIdiom(aIdiom[nIdiom])
        cValue := FwI18NLang(cSource, "STR" + cChave, Val(cChave))
        nSize  := Max(nSize, Len(cValue))
    Next

    FwSetIdiom(cIdiom)

    aComment := {"Label from Source   : " + cSource,;
                 "Original Portuguese : '" + cValue + "'",;
                 "Suggested Size Limit: " + CValToChar(nSize)}
   
    cName  := RTrim(ZA1->(ZA1_IDIOM + ZA1_ORIGIN + ZA1_KEY))
    cValue := FwI18NLang(cSource, "STR" + cChave, Val(cChave))

    AAdd(aStrings, {ZA1->(RECNO()), cName, cValue, aComment})

Return

Static Function UpdZA1Status(aZA1Recnos)

    Local nZA1Rec := 0

    For nZA1Rec := 1 to Len(aZA1Recnos)
        If !Empty(aZA1Recnos[nZA1Rec, 1])
            ZA1->(DbGoTo(aZA1Recnos[nZA1Rec, 1]))
            RecLock("ZA1", .F.)
            ZA1->ZA1_HIST  := u_ZA1Hist("Translate Document Created.")
            ZA1->(MsUnlock())
        EndIf
    Next

Return

Static Function IdiomTo()

    Local aConfig    := StrTokArr(GetNewPar("FS_SMACAT1", "000000|en|ru"), "|")
    Local cIdiomTo := aConfig[3]

Return cIdiomTo


User Function GetZA1Rec(cName)
    
    Local nZA1Rec := 0
    Local cAliasZA1 := GetNextAlias()
    Local cIdiom  := ""  
    Local cOrigin := ""   
    Local cKey    := ""
   
    cIdiom  := SubStr(cName, 1                             , Len(ZA1->ZA1_IDIOM ))
    cOrigin := SubStr(cName, Len(cIdiom) + 1               , Len(ZA1->ZA1_ORIGIN))
    cKey    := SubStr(cName, Len(cOrigin) + Len(cIdiom) + 1, Len(ZA1->ZA1_KEY   ))

    BeginSQL Alias cAliasZA1    
         SELECT ZA1.R_E_C_N_O_ ZA1REC
           FROM %Table:ZA1% ZA1
          WHERE ZA1_ORIGIN = %Exp:cOrigin%
            AND ZA1_IDIOM  = %Exp:cIdiom%
            AND ZA1_KEY    = %Exp:cKey%
            AND ZA1_FLAV = 'TRANSL'
            AND ZA1.%NotDel%
    EndSQL

    If (cAliasZA1)->(!EoF())
        nZA1Rec := (cAliasZA1)->ZA1REC
    EndIf

    (cAliasZA1)->(!DbCloseArea())

Return nZA1Rec

Static Function StrNotTrans(aStrings)
Local lRet:=    .F.
Local nX := 1
For nX:=1 To Len(aStrings)
    If !IsRussian(aStrings[nX,3])
        lRet:=  .T.
        Exit
    Endif
Next

Return lRet

Static Function IsRussian(cTexto)
Local lRet as Logical
Local nX as Numeric
Local nLength as Numeric
Local nTotAsc as Numeric
Local nLenCon as Numeric
Local nAscLet as Numeric
Local lSoSimbol as Logical
Local lSimbolo as Logical
Local nAvgAsc as Numeric
//Arranca os TAGS de marca
cTexto:= StrTran(cTexto,'#_BRAND_#','')
cTexto:= StrTran(cTexto,'#_PRODUCT_#','')
cTexto:= StrTran(cTexto,'#_COMPANY_#','')
cTexto:= StrTran(cTexto,'#_WEBSITE_#','')
cTexto:= StrTran(cTexto,'#_LINE_PRODUCT_#','')
cTexto:= StrTran(cTexto,'#_LINE_#','')
cTexto:= StrTran(cTexto,'#_WEBHELP_#','')

nAvgAsc           := 0
lRet        := .T.
cTexto            := alltrim(cTexto)
nLength           := len(cTexto)
nLenCon           := 0
lSoSimbol   := .T.
lSimbolo    := .F.
//Exceptions
iF UPPER(substr(CtEXTO,1,3))=='ÎÁÍ'
	lRet := .T.
ELSEIf nLength > 0
      nTotAsc     := 0
      For nX := 1 to nLength
            nAscLet := asc(substr(cTexto,nX,1))
            
            If nAscLet >= 192 .and. nAscLet <= 255 
                  // cirilico = 192 -> 255
                  lSoSimbol   := .F.
                  nLenCon     += 1
                  nTotAsc           += nAscLet
            Else
                  lSimbolo := (nAscLet < 64) .or. (nAscLet >= 91 .and. nAscLet <= 96) .or. (nAscLet >= 123 .and. nAscLet <= 191) // simbolo 
                  If !lSimbolo
                        // alfabeto ocidental = asc 65 -> 90, 97 -> 122
                        lSoSimbol   := .F.                  
                        nLenCon     += 1
                        nTotAsc           += nAscLet
                  Endif   
            Endif 
      Next nX

      If lSoSimbol // string possui somente simbolos, numeros ou caracters de controle
            lRet := .T.      
      Else
            If nLenCon > 0 // somente considerando as letras do alfabeto ocidental e cirilico
                  nAvgAsc := nTotAsc / nLenCon
            Endif
      
            If nAvgAsc > 127 .or. nLenCon = 0 
                  lRet := .T.
            Else
                  lRet := .F.
            Endif
      Endif
Endif

Return lRet

// Russia_R5
