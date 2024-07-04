#include "protheus.ch"

/** {Protheus.doc} OGB002
Ajusta data Romaneio Simbolico/Retenção

@param:     Nil
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

Function OGB002()
    Local aAreaAtu    := GetArea()
    Local oReport     := Nil
    Private vVetRom, vRetRom
    Private cNoT1, cAlT1, aAlT1
    
    Private cPergunta := "OGB002001"
    
    /*+===============================================+
    || ARQUIVO TEMPORARIO -- Romaneios               ||
    +================================================*/
    vVetRom := {    {"NJJ_FILIAL"},;
                    {"NJJ_CODROM"},; 
                    {"NJJ_DATA"},;                    
                    {"DATPS1","C", 10, 0, "Data Peso 1", "@!"},; 
                    {"DATPS2","C", 10, 0, "Data Peso 2", "@!"},;                
                    {"PESO1", "C", TamSX3("NJJ_PESO1")[1]+TamSX3("NJJ_PESO1")[2]  ,0,  "Pesagem 1", "@!"},;
                    {"PSSUBT","C", TamSX3("NJJ_PSSUBT")[1]+TamSX3("NJJ_PSSUBT")[2],0 , "Peso Subtot", "@!"},;
                    {"PSBASE","C", TamSX3("NJJ_PSBASE")[1]+TamSX3("NJJ_PSBASE")[2],0,  "Peso Base", "@!"},; 
                    {"PSLIQU","C", TamSX3("NJJ_PSLIQU")[1]+TamSX3("NJJ_PSLIQU")[2],0,  "Peso Liquido", "@!"} }                    
    
    vRetRom := AGRCRIATRB(,vVetRom,{"NJJ_FILIAL+NJJ_CODROM"},"OGB002",.T.) //"OGR341"   //FUNCAO DO AGRUTIL01
    cNoT1 := vRetRom[3] //INDICE
    cAlT1 := vRetRom[4] //ALIAS        
    aAlT1 := vRetRom[5] //ARRAY 


    If TRepInUse()
        Pergunte( cPergunta, .f. )
        oReport := ReportDef()
        oReport:PrintDialog()

    EndIf

    RestArea( aAreaAtu )

    //destroi tabela temporária
    AGRDELETRB( cAlT1, cNoT1 )  
Return( Nil )

/** {Protheus.doc} PrintReport
Constroi o layout do relatório.
@param:     oReport
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function ReportDef()
    Local oReport       := Nil
    Local oSection1 := Nil
    
    oReport := TReport():New("OGB002", "Alteração de Data/Peso Romaneios Simbólico e Retenção", cPergunta, {| oReport | PrintReport( oReport ) }, "Alteração de Data/Peso Romaneios Simbólico e Retenção")
    
    oReport:SetTotalInLine( .f. )
    oReport:SetLandScape()  
    
    /*Monta as Colunas*/
    
    oSection1 := TRSection():New( oReport, "Romaneios", cAlT1 ) 

    TRCell():New( oSection1, "NJJ_FILIAL"   , cAlT1)
    TRCell():New( oSection1, "NJJ_CODROM"   , cAlT1)  
    TRCell():New( oSection1, "NJJ_DATA"     , cAlT1)  
    TRCell():New( oSection1, "DATPS1"   , cAlT1, "Data Peso 1",'@!',10)   
    TRCell():New( oSection1, "DATPS2"   , cAlT1, "Data Peso 2",'@!',10 ) 
    TRCell():New( oSection1, "PESO1"    , cAlT1, "Pesagem 1",'@!', TamSX3("NJJ_PESO1")[1]+TamSX3("NJJ_PESO1")[2] )   
    TRCell():New( oSection1, "PSSUBT"   , cAlT1, "Peso Subtot",'@!',TamSX3("NJJ_PSSUBT")[1]+TamSX3("NJJ_PSSUBT")[2] )
    TRCell():New( oSection1, "PSBASE"   , cAlT1, "Peso Base",'@!',TamSX3("NJJ_PSBASE")[1]+TamSX3("NJJ_PSBASE")[2] ) 
    TRCell():New( oSection1, "PSLIQU"   , cAlT1, "Peso Liquido",'@!',TamSX3("NJJ_PSLIQU")[1]+TamSX3("NJJ_PSLIQU")[2] ) 
   

Return( oReport )

/** {Protheus.doc} PrintReport
Gerar o relatório.
@param:     oReport
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function PrintReport( oReport ) 
    Local oS1       := oReport:Section( 1 )
           
                
    If oReport:Cancel()
        Return( Nil )
    EndIf
            
    CriaTT() //cria a tabela temporária dos dados

    DbSelectArea( cAlt1 )
    (cAlt1)->( dbGoTop() )
    
    oS1:Init()
    
    While .Not. (cAlt1)->( Eof( ) )
        
        oS1:PrintLine( )
                    
        (cAlt1)->( dbSkip() )
    EndDo
    
    oS1:Finish()       
        
Return( )


/** {Protheus.doc} CriaTT
Atualiza base e cria lista de dados.
@param:     nil
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

static Function CriaTT(cFiltro)
    Local cDATPS1, cDATPS2, cPESO1, cPSSUBT, cPSBASE, cPSLIQU
    Private cAliasNJJ := GetNextAlias() //Itens do Romaneios


    //Query Romaneios  
    BeginSql Alias cAliasNJJ
        Select *
        From %table:NJJ% NJJ
        WHERE NJJ.%notDel%
          AND (NJJ.NJJ_TIPENT = "2" OR NJJ.NJJ_TIPENT = "3") //somente simbolicos e de retenção
          AND (NJJ.NJJ_DATPS1 = "" OR NJJ.NJJ_DATPS2 = "" OR NJJ.NJJ_QTDFIS > 0 )          
    EndSQL


    DbSelectArea( cAliasNJJ )
    (cAliasNJJ)->( dbGoTop() )

    While .Not. (cAliasNJJ)->( Eof( ) )
           
        
        /*************Set Variaveis****************/
        cDATPS1 := iIf( empty((cAliasNJJ)->NJJ_DATPS1), Stod((cAliasNJJ)->NJJ_DATA), Nil)     
        cDATPS2 := iIf( empty((cAliasNJJ)->NJJ_DATPS2), Stod((cAliasNJJ)->NJJ_DATA), Nil)     
        
        if .not. empty((cAliasNJJ)->NJJ_QTDFIS)
            cPESO1  := iIf( empty((cAliasNJJ)->NJJ_PESO1), (cAliasNJJ)->NJJ_QTDFIS, Nil)     
            cPSSUBT := iIf( empty((cAliasNJJ)->NJJ_PSSUBT), (cAliasNJJ)->NJJ_QTDFIS, Nil)  
            cPSBASE := iIf( empty((cAliasNJJ)->NJJ_PSBASE), (cAliasNJJ)->NJJ_QTDFIS, Nil)  
            cPSLIQU := iIf( empty((cAliasNJJ)->NJJ_PSLIQU), (cAliasNJJ)->NJJ_QTDFIS, Nil)     
        else 
            cPESO1  := nil
            cPSSUBT := nil
            cPSBASE := nil
            cPSLIQU := nil
        endif
           
        //tem algo para atualizar   
        if .not. (empty(cDATPS1) .and. empty(cDATPS2) .and. empty(cPESO1) .and. empty(cPSSUBT) .and. empty(cPSBASE) .and. empty(cPSLIQU)) 
           
           if mv_par01 = 2 //atualiza o registro
                dbSelectArea("NJJ")
                NJJ->( dbSetOrder( 1 ) )
                If dbSeek( (cAliasNJJ)->NJJ_FILIAL + (cAliasNJJ)->NJJ_CODROM ) 
                    RecLock( "NJJ", .f. )
                      
                        if .not. empty(cDATPS1)
                            NJJ->NJJ_DATPS1 := cDATPS1
                        endif
                        
                        if .not. empty(cDATPS2)
                            NJJ->NJJ_DATPS2 := cDATPS2
                        endif
                        
                        if .not. empty(cPESO1)
                            NJJ->NJJ_PESO1 := cPESO1
                        endif
                        
                        if .not. empty(cPSSUBT)
                            NJJ->NJJ_PSSUBT := cPSSUBT
                        endif
                        
                        if .not. empty(cPSBASE)
                            NJJ->NJJ_PSBASE := cPSBASE
                        endif
                        
                        if .not. empty(cPSLIQU)
                            NJJ->NJJ_PSLIQU := cPSLIQU
                        endif 
                                                                
                    NJJ->(MsUnLock())                    
                endif                  
            end
            
            DbSelectArea( cAlt1 )
            Reclock(cAlt1, .T.)
                (cAlt1)->NJJ_FILIAL := (cAliasNJJ)->NJJ_FILIAL
                (cAlt1)->NJJ_CODROM := (cAliasNJJ)->NJJ_CODROM
                (cAlt1)->NJJ_DATA   := StoD((cAliasNJJ)->NJJ_DATA)
                (cAlt1)->DATPS1     := iIf( empty(cDATPS1), nil ,  TRANSFORM(Dtoc(cDATPS1),"99/99/9999"))  
                (cAlt1)->DATPS2     := iIf( empty(cDATPS2), nil ,  TRANSFORM(Dtoc(cDATPS2),"99/99/9999"))     
                (cAlt1)->PESO1      := iIf( empty(cPESO1),  "" , TRANSFORM((cAliasNJJ)->NJJ_QTDFIS,PesqPict('NJJ',"NJJ_PESO1")))    
                (cAlt1)->PSSUBT     := iIf( empty(cPSSUBT), "" , TRANSFORM((cAliasNJJ)->NJJ_QTDFIS,PesqPict('NJJ',"NJJ_PSSUBT")))   
                (cAlt1)->PSBASE     := iIf( empty(cPSBASE), "" , TRANSFORM((cAliasNJJ)->NJJ_QTDFIS,PesqPict('NJJ',"NJJ_PSBASE")))    
                (cAlt1)->PSLIQU     := iIf( empty(cPSLIQU), "" , TRANSFORM((cAliasNJJ)->NJJ_QTDFIS,PesqPict('NJJ',"NJJ_PSLIQU")))  
            MsUnlock()

        endIF
        
        (cAliasNJJ)->( dbSkip() )       
    end
    (cAliasNJJ)->(dbCloseArea())
   

return()
