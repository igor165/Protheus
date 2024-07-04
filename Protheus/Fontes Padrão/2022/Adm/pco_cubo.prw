#INCLUDE "PROTHEUS.CH"

// --------------------------------------------------------------------------------
// Declaracao da Classe Cubes_Set
// --------------------------------------------------------------------------------

CLASS Cubes_Set
// Declaracao das propriedades da Classe
DATA aCubes_Set
DATA nLinePosition
DATA nNumCubes

// Declaração dos Métodos da Classe
METHOD New() CONSTRUCTOR
METHOD GetCube_Set()
METHOD SetAddCube_Set(oCube)
METHOD GetCube()
METHOD CountCube()
METHOD GetPosition()
METHOD SetPosition(nLinePosition)
ENDCLASS

// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS Cubes_Set
Self:aCubes_Set := {}
Self:nLinePosition := 0
Self:nNumCubes := 0
Return Self

METHOD GetCube_Set() CLASS Cubes_Set
Return Self:aCubes_Set

METHOD SetAddCube_Set(oCube) CLASS Cubes_Set
aAdd(Self:aCubes_Set, oCube)
Self:nNumCubes++
Return 

METHOD GetCube() CLASS Cubes_Set
Return Self:aCubes_Set[Self:nLinePosition]

METHOD CountCube() CLASS Cubes_Set
Return Self:nNumCubes

METHOD GetPosition() CLASS Cubes_Set
Return Self:nLinePosition

METHOD SetPosition(nLinePosition) CLASS Cubes_Set
Self:nLinePosition := nLinePosition
Return 


// --------------------------------------------------------------------------------
// Declaracao da Classe Managerial_Cubes
// --------------------------------------------------------------------------------

CLASS Managerial_Cubes
// Declaracao das propriedades da Classe
DATA Cube_DataGeneral
DATA Cube_Struct
DATA Cube_Configuration
DATA Cube_BlockTypes

// Declaração dos Métodos da Classe
METHOD New() CONSTRUCTOR
METHOD GetCube_DataGeneral()
METHOD SetCube_DataGeneral(oLstRec)
METHOD GetCube_Struct()
METHOD SetCube_Struct(oLstRec)
METHOD GetCube_Configuration()
METHOD SetCube_Configuration(oCubeCfg)
METHOD GetCube_BlockTypes()
METHOD SetCube_BlockTypes(oLstRec)
ENDCLASS

// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS Managerial_Cubes
Self:Cube_DataGeneral := NIL
Self:Cube_Struct := NIL
Self:Cube_Configuration := NIL
Self:Cube_BlockTypes := NIL

Return Self

METHOD GetCube_DataGeneral() CLASS Managerial_Cubes
Return Self:Cube_DataGeneral

METHOD SetCube_DataGeneral(oLstRec) CLASS Managerial_Cubes
Self:Cube_DataGeneral := oLstRec
Return 

METHOD GetCube_Struct() CLASS Managerial_Cubes
Return Self:Cube_Struct

METHOD SetCube_Struct(oLstRec) CLASS Managerial_Cubes
Self:Cube_Struct := oLstRec
Return 

METHOD GetCube_Configuration() CLASS Managerial_Cubes
Return Self:Cube_Configuration

METHOD SetCube_Configuration(oCubeCfg) CLASS Managerial_Cubes
Self:Cube_Configuration := oCubeCfg
Return 

METHOD GetCube_BlockTypes() CLASS Managerial_Cubes
Return Self:Cube_BlockTypes

METHOD SetCube_BlockTypes(oLstRec) CLASS Managerial_Cubes
Self:Cube_BlockTypes := oLstRec
Return 

// --------------------------------------------------------------------------------
// Declaracao da Classe Set_of_Cfg_Cube
// --------------------------------------------------------------------------------

CLASS Set_of_Cfg_Cube
// Declaracao das propriedades da Classe
DATA aCubeCfg_Set
DATA nLinePosition
DATA nNumConfig

// Declaração dos Métodos da Classe
METHOD New() CONSTRUCTOR
METHOD GetCubeCfg_Set()
METHOD SetAddCfgCube_Set(oCfgCube)
METHOD GetConfig()
METHOD CountConfig()
METHOD GetPosition()
METHOD SetPosition(nLinePosition)
ENDCLASS

// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS Set_of_Cfg_Cube
Self:aCubeCfg_Set := {}
Self:nLinePosition := 0
Self:nNumConfig := 0
Return Self

METHOD GetCubeCfg_Set() CLASS Set_of_Cfg_Cube
Return Self:aCubeCfg_Set

METHOD SetAddCfgCube_Set(oCfgCube) CLASS Set_of_Cfg_Cube
aAdd(Self:aCubeCfg_Set, oCfgCube)
Self:nNumConfig++
Return 

METHOD GetConfig() CLASS Set_of_Cfg_Cube
Return Self:aCubeCfg_Set[Self:nLinePosition]

METHOD CountConfig() CLASS Set_of_Cfg_Cube
Return Self:nNumConfig

METHOD GetPosition() CLASS Set_of_Cfg_Cube
Return Self:nLinePosition

METHOD SetPosition(nLinePosition) CLASS Set_of_Cfg_Cube
Self:nLinePosition := nLinePosition
Return 

// --------------------------------------------------------------------------------
// Declaracao da Classe Configuration_Cube
// --------------------------------------------------------------------------------

CLASS Configuration_Cube
// Declaracao das propriedades da Classe
DATA CubeCfg_DataGeneral
DATA CubeCfg_Structure

// Declaração dos Métodos da Classe
METHOD New() CONSTRUCTOR
METHOD GetCubeCfg_DataGeneral()
METHOD SetCubeCfg_DataGeneral(oLstRec)
METHOD GetCube_StructCfg()
METHOD SetCube_StructCfg(oLstRec)
ENDCLASS

// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS Configuration_Cube
Self:CubeCfg_DataGeneral := NIL
Self:CubeCfg_Structure := NIL
Return Self

METHOD GetCubeCfg_DataGeneral() CLASS Configuration_Cube
Return Self:CubeCfg_DataGeneral

METHOD SetCubeCfg_DataGeneral(oLstRec) CLASS Configuration_Cube
Self:CubeCfg_DataGeneral := oLstRec
Return 

METHOD GetCube_StructCfg() CLASS Configuration_Cube
Return Self:CubeCfg_Structure

METHOD SetCube_StructCfg(oLstRec) CLASS Configuration_Cube
Self:CubeCfg_Structure := oLstRec
Return 

/* ----------------------------------------------------------------------------

_PCO_CUBE()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _PCO_CUBE()
Return Nil	