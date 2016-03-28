---
title: LFS API Reference

language_tabs:
  - lua

toc_footers:
  - <a href="https://github.com/ikCourage/LFS" target="_blank">github</a>
  - <a href="https://git.oschina.net/ikCourage/LFS_FREE" target="_blank">git@osc</a>
  - <a href="http://github.com/tripit/slate" target="_blank">Powered by Slate</a>

search: true
---

# Introduction

Welcome LFS API

LFS 是非常非常快的文件系统，可以同时存储海量大文件和小文件，高并发。

许多存储方案或者优于存储大文件，或者优于存储小文件，在 LFS 中则一视同仁。所以既可以用来存储视频音乐，也可以用来存储图片。

使用 LFS 可以轻易构建出一个倒排：[example](#InvertFile)。

LFS 的有趣之处在于，[DataFile](#DataFile) 具有类似数组的特性，看起来就像是控制数组而不是数据。

LFS 使用 lua 作为脚本语言（快并且简单），可以提供更细致的逻辑处理。

共有 [LFS](#LFS)，[vars](#vars), [out](#out), [buffer](#buffer) 这几个全局对象。（清晰明了）

链接：<a href="https://github.com/ikCourage/LFS" target="_blank">github</a> <a href="https://git.oschina.net/ikCourage/LFS_FREE" target="_blank">git@osc</a>


<h1 id="LFS">LFS</h1>

### LFS 中定义的类

Class | Description
----- | -----------
[DataFile](#DataFile) | 普通的数据文件：提供原始数据的读写（最常用的类, 几乎所有的操作都基于此）
[UniqueFile](#UniqueFile) | 唯一文件：通过 IndexKey 来标识记录的唯一性
[InvertFile](#InvertFile) | 倒排文件：用来存储指向一个 [相同属性] 的所有记录 ID
[IndexKey](#IndexKey) | 索引 key：将字符串或字节数组转换成可被索引的哈希
[ByteArray](#ByteArray) | 字节数组：提供对原始字节的高级读写



<h1 id="vars">vars <em><code>global</code></em></h1>

[read-only] 客户端传入的变量数组，下标从 0 开始。


<h2 id="vars_length">length <em><code>property</code></em></h2>

`length:uint` [read-only]

变量数组的长度。


<h2 id="vars_getLength">getLength</h2>

`getLength(index:uint):uint`

返回数组中 index 指定位置的变量长度。


<h2 id="vars_getType">getType</h2>

`getType(index:uint):int`

返回数组中 index 指定位置的变量类型。

Return | Type
------ | ----
1 | byte
-1 | ubyte
2 | short
3 | ushort
4 | int
5 | uint
6 | float
7 | double
8 | long
-4 | String
-5 | StringBytes
-3 | bytes
-2 | Boolean
0 | null



<h1 id="buffer">buffer <em><code>global</code></em></h1>

`buffer` 是一个 ByteArray 对象。

当从 DataFile 等文件中读取文档时，会自动读入到 `buffer` 中，然后通过 ByteArray 的方法对数据进行访问。


<h2 id="buffer_sizeTotal">sizeTotal <em><code>property</code></em></h2>

`sizeTotal:ulong` [read-only]

当从 DataFile 等文件中读取文档时，`sizeTotal` 会返回文档的总大小。



<h1 id="out">out <em><code>global</code></em></h1>

输出字节流：用来将数据返回给客户端。


<h2 id="out_setState">setState</h2>

`setState(state:int):void`

设置返回给客户端的状态。（0 为成功）

通过设置 `state` 来简便指定当前执行是否成功。

<aside class="notice">

<code>state</code> 为用户自己设定的状态，不要与客户端的 <code>status</code> 弄混。（<code>status</code> 表示语句是否执行成功。若语法错误或运行时错误则 <code>status</code> 不为 0）

</aside>


<h2 id="out_getState">getState</h2>

`getState():int`

返回当前的执行状态。若从未设置过 `state`，则一直为默认值：0。


<h2 id="out_setPosition">setPosition</h2>

> 修改一个已经存在于 `out` 中的值

```lua
local resultState_position = out:getPosition(); -- 首先记录下 position
out:putInt(0); -- 占位（此时尚未知道执行结果。假设返回的数据结构要求 resultState 放在头部）
out:putString(str);
-- 省略部分语句
local current_position = out:getPosition(); -- 记录下当前的 position
out:setPosition(resultState_position); -- 设置回需要添加头的位置
out:putInt(resultState); -- 将 resultState 写入之前占位的地方
out:setPosition(current_position); -- 重新设置回最后的位置，因为接下来还需要返回其他内容
-- 省略部分语句
out:putString(str2);
```


`setPosition(position:uint):void`

设置当前的偏移。

<aside class="warning">

请谨慎使用此方法。此方法只用来修改已经添加进 <code>out</code> 中的值。请务必确保 position 不会打乱 <code>out</code> 中的字节。

</aside>


<h2 id="out_getPosition">getPosition</h2>

`getPosition():uint`

返回当前的偏移位置。


<h2 id="out_putString">putString</h2>

`putString(str:Bytes, offset:uint = 0, length:uint = 0):void`

类似：[ByteArray:writeBytes](#ByteArray_writeBytes)


<h2 id="out_putStringBytes">putStringBytes</h2>

`putStringBytes(strBytes:Bytes, offset:uint = 0, length:uint = 0):void`

类似：[ByteArray:writeBytes](#ByteArray_writeBytes)


<h2 id="out_putBytes">putBytes</h2>

`putBytes(bytes:Bytes, offset:uint = 0, length:uint = 0):void`

类似：[ByteArray:writeBytes](#ByteArray_writeBytes)


<h2 id="out_putBoolean">putBoolean</h2>

`putBoolean(value:Boolean):void`

<h2 id="out_putByte">putByte</h2>

`putByte(value:byte):void`

<h2 id="out_putUByte">putUByte</h2>

`putUByte(value:ubyte):void`

<h2 id="out_putShort">putShort</h2>

`putShort(value:short):void`

<h2 id="out_putUShort">putUShort</h2>

`putUShort(value:ushort):void`

<h2 id="out_putInt">putInt</h2>

`putInt(value:int):void`

<h2 id="out_putUInt">putUInt</h2>

`putUInt(value:uint):void`

<h2 id="out_putLong">putLong</h2>

`putLong(value:long):void`

<h2 id="out_putFloat">putFloat</h2>

`putFloat(value:float):void`

<h2 id="out_putDouble">putDouble</h2>

`putDouble(value:double):void`

<h2 id="out_putNull">putNull</h2>

`putNull():void`



<h1 id="DataFile">DataFile <em><code>Class</code></em></h1>

普通的数据文件：提供原始数据的读写（最常用的类, 几乎所有的操作都基于此）

一个 DataFile 最多可以存储 2^32 - 1 个记录（每个记录即表示为一个独立的文档，所有的“记录”或“文档”表示相同的概念）

<h2 id="DataFile_new">new <em><code>constructor</code></em></h2>

`new(path:String = null):DataFile`


<h2 id="DataFile_open">open</h2>

> 打开文件

```lua
local photosFile = LFS.DataFile.new();
photosFile:open("app/photos");
```

`open(path:String):void`

打开文件


<h2 id="DataFile_setOne">setOne</h2>

> 该操作等同于

```lua
if (myFile:getTotalFile() == 0) then;
    myFile:write(0, nil, 0); -- 占用一个空的记录
    myFile:remove(0); -- 删除该记录，用来保证 getFileLength 的值是正确的
end;
```


`setOne(value:Boolean):void`

设置文档 id 是否跳过 0 从 1 开始。

<aside class="notice">

如果文档 id 需要添加进倒排 <a href="#InvertFile">InvertFile</a> 中，应设为 <code>true</code>。

</aside>


<h2 id="DataFile_setSize">setSize</h2>

`setSize(id:long, sizeTotal:ulong, sizeBlockMin:uint = 0, flag:uint = 0):long`

根据 id 设置文档的大小，返回真实的文档 id

参见 [write](#DataFile_write)


<h2 id="DataFile_write">write</h2>

> 追加一个图片文档

```lua
local photoBytes = vars[1]; -- 从传入的数组中取出图片数据
local id = photosFile:write(-1, photoBytes);
out:putLong(id); -- 返回文档 id
```

> 更新文档

```lua
local text = "new document";
local id = myFile:write(-1, text, -1, 0, 0, 3);
text = "update text";
id = myFile:write(id, text, 6, 4, 0, 3); -- result: "new updatent"
```

`write(id:long, buffer:byte[], bufferLength:ulong = MAX, offset:ulong = 0, sizeBlockMin:uint = 0, flag:uint = 0):long`

根据 id 写入数据，并返回真实的记录 id（0 <= id < 2^32），如果返回的 id < 0 则表示失败。

Parameter | Default | Description
--------- | ------- | -----------
id | 0 | 不能为空（-1 <= id < 2^32），-1 表示写入新的记录
buffer | null | 不能为空。如果为空，此时将写入空的记录，如果原来该记录存在数据，将会被删除
bufferLength | MAX | 默认等于 buffer.length（0 <= bufferLength <= buffer.length）
offset | 0 | 起始偏移（注意：这是 id 指向的记录的偏移，而不是 buffer 的偏移）
sizeBlockMin | 0 | 如果当前需要写入的数据长度小于 sizeBlockMin，则用字节 0 补齐（相当于为将要写的 block 分配可用空间，如果此记录的数据长度频繁增长，将会有效提高写入效率。比如：倒排文件(InvertFile)就是一个非常典型的用例）
flag | 0 | 操作标识，有效值为 0, 1, 2, 3

### flag

<aside class="warning">

flag 应该成对使用：<code>0 :: 2 or 1 :: 3</code>，或者直接简单粗暴的使用 <b>2</b> or <b>3</b>

</aside>

Value | Description
----- | -----------
0 | 先删除旧的数据，然后写入新的数据
**2** | 在 0 的基础上覆盖写入数据。如果新的数据大于原来的数据，溢出的内容会写入到溢出的 block 里；但是，为了记录溢出的指针，旧的数据会产生数据迁移。（如果数据溢出频繁，应选择 3 的方式）
1 | 先删除旧的数据，然后写入新的数据，但会额外记录一个溢出块的指针（即使此时数据尚未溢出，也会记录一个空的指针）
**3** | 在 1 的基础上覆盖写入数据。不同于 2 的是，此时不会涉及到旧数据的迁移，因为，在 1 的基础上已经分配了溢出指针的空间


<h2 id="DataFile_read">read</h2>

> 读取一个图片文档

```lua
local id = 1;
local state = photosFile:read(id);
if (state == 1) then; -- 判断是否存在数据
    out:putBytes(buffer); -- 返回图片内容
end;
```

> 获取文档的总大小

```lua
local state = photosFile:read(2, 0, 1024);
if (state == 1) then;
    out:putInt(buffer.sizeTotal); -- 文档的总大小可以通过 buffer.sizeTotal 获取到
    out:putInt(buffer.length); -- 本次调用 read 读取的真正长度，buffer.length <= sizeMaxRead
end;
```

> 判断该记录是否为空，或者是否已经删除

```lua
local state = photosFile:read(3, 0, 1); -- 最多仅读取 1 个字节
if (state == 0) then;
    -- 该记录为空
elseif (state == -7) then;
    -- 该记录已经删除
end;
```


`read(id:long, offset:ulong = 0, sizeMaxRead:uint = 0):int`

根据记录 id 读取数据，返回成功或失败

<aside class="notice">

读取出的内容缓存在全局变量 <a href="#buffer">buffer</a> 中

</aside>

Parameter | Default | Description
--------- | ------- | -----------
id | 0 | 文档 id（0 <= id < 2^32）
offset | 0 | 文档内的起始偏移，从此位置开始读取数据
sizeMaxRead | 0 | 如果不为 0 则最多读取 sizeMaxRead 的数据（因为文档的总大小可能并不大于 sizeMaxRead）

Return | Description
------ | -----------
1 | 成功
0 | 成功，但这是一个空记录，数据长度为 0
-7 | 该记录已经删除
-2 | id 不合法，超出有效范围（0 <= id < 2^32）
-4 | 通过 open 打开的文件不存在


<h2 id="DataFile_remove">remove</h2>

> 删除一个图片

```lua
local id = vars[1]; -- 从传入的数组中取出需要删除的图片 id
local state = photosFile:remove(id);
out:putInt(state); -- 返回删除的状态
```

`remove(id:long):int`

删除记录

<aside class="notice">

已删除的文档空间并不会立刻回收

</aside>

Return | Description
------ | -----------
1 | 成功
-7 | 该记录已经删除
-2 | id 不合法，超出有效范围（0 <= id < 2^32）
-4 | 通过 open 打开的文件不存在


<h2 id="DataFile_getTotalFile">getTotalFile</h2>

> 获取 "app/photos" 里的总文档数量

```lua
local photosFile = LFS.DataFile.new("app/photos");
out:putInt(photosFile:getTotalFile()); -- 返回总文档数量
```

`getTotalFile():uint`

返回总文档数量（包含已经删除的）


<h2 id="DataFile_getFileLength">getFileLength</h2>

> 获取 "app/photos" 里的有效文档数量

```lua
local photosFile = LFS.DataFile.new("app/photos");
out:putInt(photosFile:getFileLength()); -- 返回有效文档数量
```

`getFileLength():uint`

返回有效文档数量


<h2 id="DataFile_getFileLengthDeleted">getFileLengthDeleted</h2>

> 获取 "app/photos" 里的已经删除的文档数量

```lua
local photosFile = LFS.DataFile.new("app/photos");
out:putInt(photosFile:getFileLengthDeleted()); -- 返回已经删除的文档数量
```

`getFileLengthDeleted():uint`

返回已经删除的文档数量


<h2 id="DataFile_indexOf">indexOf</h2>

`indexOf(bytes:Bytes, fromIndex:uint = 0, endIndex:uint = MAX, length:uint = MAX, offset:ulong = 0, strict:Boolean = false):long`

从前向后搜索每个文档，返回匹配的文档 id，如果 id < 0 则没有找到匹配的文档。

Parameter | Default | Description
--------- | ------- | -----------
bytes | nil | 匹配的内容
fromIndex | 0 | 搜索的开始位置（开始文档 id）。默认为第一个文档。
endIndex | MAX | 搜索的结束位置（结束文档 id）。默认为最后一个文档。
length | MAX | bytes 的范围：bytes[0 - length]
offset | 0 | 文档中从 offset 位置开始匹配 bytes[0 - length]
strict | false | 是否严格检查 sizeTotal 和 length 相等。（只有 offset 为 0 时才有意义）


<h2 id="DataFile_lastIndexOf">lastIndexOf</h2>

`lastIndexOf(bytes:Bytes, fromIndex:uint = 0, endIndex:uint = MAX, length:uint = MAX, offset:ulong = 0, strict:Boolean = false):long`

从后向前搜索每个文档，返回匹配的文档 id，如果 id < 0 则没有找到匹配的文档。

Parameter | Default | Description
--------- | ------- | -----------
bytes | nil | 匹配的内容
fromIndex | MAX | 搜索的开始位置（开始文档 id）。默认为最后一个文档。
endIndex | 0 | 搜索的结束位置（结束文档 id）。默认为第一个文档。
length | MAX | bytes 的范围：bytes[0 - length]
offset | 0 | 文档中从 offset 位置开始匹配 bytes[0 - length]
strict | false | 是否严格检查 sizeTotal 和 length 相等。（只有 offset 为 0 时才有意义）


<h2 id="DataFile_close">close</h2>

> 关闭打开的文件

```lua
myFile:close();
myFile:open("app/photos"); -- 打开其他文件
```

`close():void`

关闭已经打开的文件，然后可以重新打开其他文件


<h2 id="DataFile_clear">clear</h2>

> 清空 DataFile 对象

```lua
myFile:clear(); -- 清空 DataFile 占用的资源
myFile = nil; -- 彻底释放 myFile 占用的所有资源
```

`clear():void`

清空 DataFile，这将关闭已经打开的文件并释放内存

<aside class="notice">

一旦使用完该实例之后，都需要进行清空，这是良好的习惯，并且也有助于提高执行效率。

</aside>



<h1 id="UniqueFile">UniqueFile <em><code>Class</code></em></h1>

唯一文件（哈希文件）：利用 IndexKey 生成的哈希来快速访问指向的文档

UniqueFile 的用途：

* 避免重复记录（唯一约束）
* 提高记录的检索速度（生成索引）
* 用来存储 key->value


<h2 id="UniqueFile_new">new <em><code>constructor</code></em></h2>

`new(path:String = null):UniqueFile`


<h2 id="UniqueFile_open">open</h2>

> 打开文件

```lua
local dictFile = LFS.UniqueFile.new();
dictFile:open("app/dict");
```

`open(path:String):void`

打开文件


<h2 id="UniqueFile_write">write</h2>

> 创建一个字典，启用唯一约束，避免存储相同的词汇（线程安全）

```lua
local indexKey = LFS.IndexKey.new();
indexKey:setKey("running man");
local id = dictFile:write(indexKey, "奔跑吧兄弟");
local id2 = dictFile:write(indexKey, "跑男"); -- id2 == id，但是 “跑男” 并没有覆盖 “奔跑吧兄弟”
out:putLong(id); -- 返回文档 id
```

> 存储 key->value（这里将 flag 设置为 **3**）

```lua
local indexKey = LFS.IndexKey.new();
indexKey:setKey("current video");
myFile:write(indexKey, "奔跑吧兄弟", -1, 0, 0, 3);
myFile:write(indexKey, "跑男来了", -1, 0, 0, 3); -- 覆盖前一个记录
```

> 上传图片，并设置"文件名"，之后就可以通过文件名来获取图片

> 通过此方法，模拟"文件路径"的访问方式

```lua
local photoBytes = vars[2];
local indexKey = LFS.IndexKey.new();
indexKey:setKey("2020/0130/1720.jpg"); -- 以"文件名"为 key 来存储图片
local id = photosFile:write(indexKey, photoBytes);
```


`write(indexKey:IndexKey, buffer:byte[], bufferLength:ulong = MAX, offset:ulong = 0, sizeBlockMin:uint = 0, flag:uint = 0):long`

根据 IndexKey 写入数据，并返回真实的记录 id（0 <= id < 2^32），如果返回的 id < 0 则表示失败

Parameter | Default | Description
--------- | ------- | -----------
indexKey | null | 不能为空，参见 [IndexKey](#IndexKey)
buffer | null | 不能为空。如果为空，此时将写入空的记录，如果原来该记录存在数据，将会被删除
bufferLength | MAX | 默认等于 buffer.length（0 <= bufferLength <= buffer.length）
offset | 0 | 起始偏移（注意：这是 id 指向的记录的偏移，而不是 buffer 的偏移）
sizeBlockMin | 0 | 如果当前需要写入的数据长度小于 sizeBlockMin，则用字节 0 补齐（相当于为将要写的 block 分配可用空间，如果此记录的数据长度频繁增长，将会有效提高写入效率。比如：倒排文件(InvertFile)就是一个非常典型的用例）
flag | 0 | 操作标识，有效值为 0, 1, 2, 3

### flag

<aside class="warning">

flag 应该成对使用：<code>0 :: 2 or 1 :: 3</code><br>

默认 flag = 0，<b>[唯一约束]</b><br>

如果用来存储 key->value，flag 应该为 <b>2</b> or <b>3</b>

</aside>

Value | Description
----- | -----------
0 | 直接存储文档内容。如果已经存在该 key，将不会覆盖旧的文档内容 **[唯一约束]**
**2** | 在 0 的基础上覆盖写入数据。如果新的数据大于原来的数据，溢出的内容会写入到溢出的 block 里；但是，为了记录溢出的指针，旧的数据会产生数据迁移。（如果数据溢出频繁，应选择 3 的方式） **[忽略唯一约束]**
1 | 在存储文档内容之前，先记录额外的溢出块的指针（即使此时数据尚未溢出，也会记录一个空的指针） **[唯一约束]**
**3** | 在 1 的基础上覆盖写入数据。不同于 2 的是，此时不会涉及到旧数据的迁移，因为，在 1 的基础上已经分配了溢出指针的空间 **[忽略唯一约束]**


<h2 id="UniqueFile_read">read</h2>

> 根据"文件名"获取图片

```lua
local indexKey = LFS.IndexKey.new();
indexKey:setKey("2020/0130/1720.jpg");
local state = photosFile:read(indexKey);
if (state == 1) then; -- 判断是否存在数据
    out:putBytes(buffer); -- 返回图片内容
end;
```

> 获取正在播放的视频（key->value）

```lua
local indexKey = LFS.IndexKey.new();
indexKey:setKey("current video");
local state = myFile:read(indexKey);
if (state == 1) then;
    out:putBytes(buffer); -- 返回正在播放的节目："跑男来了"
end;
```


`read(indexKey:IndexKey, offset:ulong = 0, sizeMaxRead:uint = 0):int`

根据 IndexKey 读取数据，返回成功或失败

<aside class="notice">

读取出的内容缓存在全局变量 <a href="#buffer">buffer</a> 中

</aside>

Parameter | Default | Description
--------- | ------- | -----------
indexKey | null | 不能为空，参见 [IndexKey](#IndexKey)
offset | 0 | 文档内的起始偏移，从此位置开始读取数据
sizeMaxRead | 0 | 如果不为 0 则最多读取 sizeMaxRead 的数据（因为文档的总大小可能并不大于 sizeMaxRead）

Return | Description
------ | -----------
1 | 成功
0 | 成功，但这是一个空记录，数据长度为 0
-7 | 该记录已经删除
-4 | 通过 open 打开的文件不存在


<h2 id="UniqueFile_remove">remove</h2>

> 删除 key 和 value

```lua
local indexKey = LFS.IndexKey.new();
indexKey:setKey("current video");
local state = myFile:remove(indexKey);
out:putInt(state); -- 返回删除的状态
```

`remove(indexKey:IndexKey):int`

删除记录

<aside class="notice">

已删除的文档空间并不会立刻回收

</aside>

Return | Description
------ | -----------
1 | 成功
-7 | 该记录已经删除
-4 | 通过 open 打开的文件不存在


<h2 id="UniqueFile_hasIndex">hasIndex</h2>

`hasIndex(indexKey:IndexKey):long`

判断是否存在该 key，返回文档 id，如果 id > 0 则存在该 key。

类似 [read](#DataFile_read)，但不区分记录是否为空


<h2 id="UniqueFile_removeIndex">removeIndex</h2>

> 删除 key，但不删除已经存储的 value（文档数据）

> 该 value 依然可以被访问

```lua
local shareFile = LFS.UniqueFile.new("app/share");
local rawFile = LFS.DataFile.new(shareFile);
local indexKey = LFS.IndexKey.new();
indexKey:setKey("music");
local id = shareFile:hasIndex(indexKey); -- 删除之前，先获得文档 id
shareFile:removeIndex(indexKey); -- 仅仅删除 key，但不删除数据
if (id >= 0) then;
    rawFile:read(id); -- 通过 id 依然可以访问存储的文档
end;
```

> 重新给一个已经删除的 key 进行赋值

> 但，这将不会覆盖原来尚未删除的文档

> 而是，会重新将一个新的文档与该 key 绑定

```lua
local id = shareFile:hasIndex(indexKey);
shareFile:removeIndex(indexKey);
local id2 = shareFile:write(indexKey, "Blank Space"); -- id != id2，两个文档都可以被访问
```


`removeIndex(indexKey:IndexKey):int`

仅仅移除 Indexkey 指定的 key，返回 1 为成功。但已经存储的 value（文档数据） 不会删除，如果需要同时删除 value，请使用 [remove](#UniqueFile_remove)

<aside class="notice">

仅仅通过 removeIndex 删除 key 而不删除 value，会影响 getFileLength 的值

</aside>


<h2 id="UniqueFile_getTotalFile">getTotalFile</h2>

`getTotalFile():uint`

返回总文档数量（包含已经删除的）

同 [DataFile:getTotalFile](#DataFile_getTotalFile)


<h2 id="UniqueFile_getFileLength">getFileLength</h2>

`getFileLength():uint`

返回有效文档数量

同 [DataFile:getFileLength](#DataFile_getFileLength)


<h2 id="UniqueFile_getFileLengthDeleted">getFileLengthDeleted</h2>

`getFileLengthDeleted():uint`

返回已经删除的文档数量

同 [DataFile:getFileLengthDeleted](#DataFile_getFileLengthDeleted)


<h2 id="UniqueFile_close">close</h2>

`close():void`

关闭已经打开的文件，然后可以重新打开其他文件


<h2 id="UniqueFile_clear">clear</h2>

`clear():void`

清空 UniqueFile，这将关闭已经打开的文件并释放内存

<aside class="notice">

一旦使用完该实例之后，都需要进行清空，这是良好的习惯，并且也有助于提高执行效率。

</aside>


<h1 id="InvertFile">InvertFile <em><code>class</code></em></h1>

> 由于倒排可能比较绕，所以展示一个完整的示例

> 在使用之前，先做一些准备工作（构建倒排索引）

> 1.存储新抓取的网页数据到网页集合中（获得 `webId`）

```lua
local webRawFile = LFS.DataFile.new("app/web");
webRawFile:setOne(true); -- 由于 webId 不能为 0，所以设置为从 1 开始
local webId = webRawFile:write(-1, vars[2]); -- 存储新抓取的网页数据，并获得该 id
```

> 2.分析出网页中包含的词汇，并建立分词索引（添加新的词汇，并获得 `wordId`）

```lua
local word = "爸爸去哪儿";
local indexKey = LFS.IndexKey.new();
indexKey:setKey(word);
local wordUniqueFile = LFS.UniqueFile.new("app/word"); -- 打开分词文件
local wordId = wordUniqueFile:write(indexKey, word); -- 将新的词汇加入索引（由于唯一约束，所以不会出现重复记录）
```

> 3.打开倒排文件，**将 `wordId->webId` 录入倒排文件中**

```lua
local sizeBlockMin = 1024 * 1024;
local word2web_InvertFile = LFS.InvertFile.new("app/word2web", sizeBlockMin, sizeBlockMin); -- 打开倒排文件
word2web_InvertFile:put(wordId, webId); -- 完成 wordId->webId 的倒排关系
```

> 到此为止，准备工作完成，倒排索引已经构建完成

> 搜索的过程：

> 1.先根据输入的词汇获得 `wordId`

```lua
local wordUniqueFile = LFS.UniqueFile.new("app/word"); -- 打开分词文件
local indexKey = LFS.IndexKey.new();
indexKey:setKey("爸爸去哪儿");
local wordId = wordUniqueFile:hasIndex(indexKey); -- 获得分词的 id
```

> 2.获得包含该分词的所有记录（从倒排中读取该集合中的所有 `webId`）

```lua
local sizeMaxRead = 1024;
local state = word2web_InvertFile:read(wordId, 0, sizeMaxRead); -- 最多读取 4 的倍数长度字节
if (state == 1) then;
    local offset = buffer.length;
    local length = buffer:readUInt(); -- 读取有效记录数量
    local lengthDeleted = buffer:readUInt(); -- 读取已经移除的记录数
    local total = length + lengthDeleted; -- 计算总记录数量
    local id;
    while (total > 0) do;
        total = total - 1;
        if (buffer.bytesAvailable > 0) then; -- 如果 buffer 中还有有效字节
            id = buffer:readUInt();
            if (id ~= 0) then;
                out:putInt(id); -- 返回不为 0 的 id 记录
            end;
        else if (total > 0) then;
            word2web_InvertFile:read(wordId, offset, math.min(sizeMaxRead, total * 4)); -- 从 offset 位置开始分片读取
            offset = offset + buffer.length;
        end;
    end;
end;
```

> 搜索过程结束


倒排文件：用来存储指向一个 [相同属性] 的所有记录 ID

比如：为搜索引擎构建倒排索引

**InvertFile 通过非常简单的方法来使这种操作变得非常简单**

<aside class="warning">

与 InvertFile 相关的 DataFile 需要设置 <a href="#DataFile_setOne">setOne(true)</a>。<b>因为 InvertFile 里的 id 不能为 0。</b>

</aside>


<h2 id="InvertFile_new">new <em><code>constructor</code></em></h2>

`new(path:String = null, sizeBlockMin:uint = 0, sizeBlockMinFirst:uint = 0):InvertFile`


参数同 [open](#InvertFile_open)


<h2 id="InvertFile_open">open</h2>

> 打开倒排文件

```lua
local sizeBlockMin = 1024 * 1024;
local word2web_InvertFile = LFS.InvertFile.new(); -- 分词指向网页的倒排表
webInvertFile:open("app/word2web", sizeBlockMin, sizeBlockMin);
```

`open(path:String, sizeBlockMin:uint = 0, sizeBlockMinFirst:uint = 0):void`

打开文件，请确保 sizeBlockMin, sizeBlockMinFirst 的值是有效的

Parameter | Default | Description
--------- | ------- | -----------
path | null | 文件路径
sizeBlockMin | 0 | 每次需要分配的最小块大小，4 的倍数（因为倒排文件里的记录 id 是不断增长的，所以预先分配合适的空间，当此空间写满之后，会继续分配另一个块空间）
sizeBlockMinFirst | 0 | 第一次需要分配的空间（第一次会额外分配 8 字节来记录有效数量和删除的数量，所以可以选择使用 sizeBlockMinFirst = sizeBlockMin + 8，也可以和 sizeBlockMin 相等）。另一种方案是：如果可以确定该倒排记录会在初期增长迅速，但达到一定程度时将不会频繁增长，那么这种情况可以将 sizeBlockMinFirst 设置为比 sizeBlockMin 大得多的值。


<h2 id="InvertFile_put">put</h2>

`put(key:uint, id:uint, sizeBlockMin:uint = null, sizeBlockMinFirst:uint = null):int`

添加 id 到 key 指向的倒排记录中，返回 >= 1 为成功。

参见 [example](#InvertFile) 中的构建倒排索引过程。

Parameter | Default | Description
--------- | ------- | -----------
key | 0 | [相同属性]的文档 id。一般情况下为通过 UniqueFile 生成的 id（即先将单词通过 UniqueFile 生成唯一索引，获得返回的 id 即为 key。所以 InvertFile 通常和 UniqueFile 一起使用）
id | 0 | id 不能为 0。id 为另一个文件中的文档 id（比如将抓取的网页记录到一个 DataFile 中，并获得返回的 id）。
sizeBlockMin | null | 若不传此参数将使用 open 时的数值
sizeBlockMinFirst | null | 若不传此参数将使用 open 时的数值


<h2 id="InvertFile_has">has</h2>

`has(key:uint, id:uint):long`

判断 key 的集合中是否包含该 id，返回 id > 0 为成功。


<h2 id="InvertFile_remove">remove</h2>

`remove(key:uint, id:uint):int`

从 key 的集合中移除该 id，返回 1 为成功


<h2 id="InvertFile_read">read</h2>

> 实际应用中，由于数组可能非常大，那么分片读取来提高效率

```lua
local sizeMaxRead = 1024;
local state = word2web_InvertFile:read(wordId, 0, sizeMaxRead); -- 最多读取 4 的倍数长度字节
if (state == 1) then;
    local offset = buffer.length;
    local length = buffer:readUInt(); -- 读取有效记录数量
    local lengthDeleted = buffer:readUInt(); -- 读取已经移除的记录数
    local total = length + lengthDeleted; -- 计算总记录数量
    local id;
    while (total > 0) do;
        total = total - 1;
        if (buffer.bytesAvailable > 0) then; -- 如果 buffer 中还有有效字节
            id = buffer:readUInt();
            if (id ~= 0) then;
                out:putInt(id); -- 返回不为 0 的 id 记录
            end;
        else;
            word2web_InvertFile:read(wordId, offset, math.min(sizeMaxRead, total * 4)); -- 从 offset 位置开始分片读取
            offset = offset + buffer.length;
        end;
    end;
end;
```


`read(key:long, offset:ulong = 0, sizeMaxRead:uint = 0):int`

同 [DataFile:read](#DataFile_read)

读取 key 的数组集合

InvertFile 中的数据格式为 uint 数组：**[ length, lengthDeleted, id1, id2, id3, `...` ]**<br>

取出数组中有效 id 的步骤为：

1. 首先通过 `total = length + lengthDeleted` 计算出总的记录数量。（计算 total 非常重要的，因为 `...` 中可能含有值为 0 的 id，这就是为什么 id 需要从 1 开始的原因。）
2. 循环遍历数组的每一项 id（从第 3 个开始），判断该 id > 0，将 total 减 1。
3. 重复 2 的步骤，直到 total 等于 0。

<aside class="notice">

实际应用中，由于数组可能非常大，无法一次性读入内存。所以使用 offset 和 sizeMaxRead 分片读入来提高效率。或者可以使用多线程来分片读取。

</aside>


<h2 id="InvertFile_close">close</h2>

`close():void`

关闭已经打开的文件，然后可以重新打开其他文件


<h2 id="InvertFile_clear">clear</h2>

`clear():void`

清空 InvertFile，这将关闭已经打开的文件并释放内存

<aside class="notice">

一旦使用完该实例之后，都需要进行清空，这是良好的习惯，并且也有助于提高执行效率。

</aside>



<h1 id="IndexKey">IndexKey <em><code>Class</code></em></h1>

索引 key：将字符串或字节数组转换成可被索引的哈希


<h2 id="IndexKey_new">new <em><code>constructor</code></em></h2>

`new():IndexKey`


<h2 id="IndexKey_setKey">setKey</h2>

`setKey(key:Bytes, size:uint = MAX):IndexKey`

将 key 进行哈希，该操作会获得两个哈希值，参见下面的方法重载。

Parameter | Default | Description
--------- | ------- | -----------
key | null | 参见 key 的类型
size | MAX | 该 key 中从 0 开始的字节长度（默认为 key 的长度）

### key 的类型
Type | Description
---- | -----------
String | 普通字符串
Bytes | 客户端传入的原始字节
ByteArray | 字节数组（从该 position 向后的字节）

`setKey(hashIndex:ulong, hash2:ulong):IndexKey`

方法重载：通过此方法，用户可以设计自己的哈希方法。

Parameter | Default | Description
--------- | ------- | -----------
hashIndex | 0 | 通过 index = hashIndex % length 来计算出索引位置
hash2 | 0 | 当 index 出现冲突时，用来进行区分的第二个哈希（注：hashIndex 不能和 hash2 相同）

<aside class="warning">

hashIndex 不能和 hash2 相同，因为通过 hashIndex 计算出相同 index 的概率太高。

</aside>


<h2 id="IndexKey_setLength">setLength</h2>

`setLength(length:uint):IndexKey`

设置哈希表的长度。length 参与 setKey 的计算，所以需要在 setKey 之前设置。（可以适当设置一个较小的值）

Parameter | Default | Description
--------- | ------- | -----------
length | 0 | 当 length 为 0 时，length = 5592405（即刚好占用一个 64M 的文件：2^26 / 12 = 5592405）


<h2 id="IndexKey_clear">clear</h2>

`clear():void`

清空 IndexKey

<aside class="notice">

一旦使用完该实例之后，都需要进行清空，这是良好的习惯，并且也有助于提高执行效率。

</aside>



<h1 id="ByteArray">ByteArray <em><code>Class</code></em></h1>

字节数组：提供对原始字节的高级读写


<h2 id="ByteArray_new">new <em><code>constructor</code></em></h2>

`new():ByteArray`


<h2 id="ByteArray_bytesAvailable">bytesAvailable <em><code>property</code></em></h2>

`bytesAvailable:uint` [read-only]

可从字节数组的当前位置到数组末尾读取的数据的字节数。

每次访问 ByteArray 对象时，将 bytesAvailable 属性与读取方法结合使用，以确保读取有效的数据。


<h2 id="ByteArray_endian">endian <em><code>property</code></em></h2>

`endian:int`

更改或读取数据的字节顺序；BIG_ENDIAN: 1 或 LITTLE_ENDIAN: 0。默认值为 BIG_ENDIAN。


<h2 id="ByteArray_length">length <em><code>property</code></em></h2>

`length:uint`

ByteArray 对象的长度（以字节为单位）。

如果将长度设置为大于当前长度的值，则用零填充字节数组的右侧。

如果将长度设置为小于当前长度的值，将会截断该字节数组。


<h2 id="ByteArray_position">position <em><code>property</code></em></h2>

`position:uint`

设置或返回 ByteArray 中的当前位置。下一次调用读取方法时将在此位置开始读取，或者下一次调用写入方法时将在此位置开始写入。


<h2 id="ByteArray_writeBytes">writeBytes</h2>

`writeBytes(bytes:Bytes, offset:uint = 0, length:uint = 0):void`

将字节数组 bytes（起始偏移量为 offset）中包含 length（默认为 bytes 的长度）个字节的字节序列写入 ByteArray。

### bytes 的类型
Type | Description
---- | -----------
String | 普通字符串
Bytes | 客户端传入的原始字节
ByteArray | 字节数组（从该 position 向后的字节）

<h2 id="ByteArray_writeBoolean">writeBoolean</h2>

`writeBoolean(value:Boolean):void`

<h2 id="ByteArray_writeByte">writeByte</h2>

`writeByte(value:byte):void`

<h2 id="ByteArray_writeShort">writeShort</h2>

`writeShort(value:short):void`

<h2 id="ByteArray_writeInt">writeInt</h2>

`writeInt(value:int):void`

<h2 id="ByteArray_writeLong">writeLong</h2>

`writeLong(value:long):void`

<h2 id="ByteArray_writeFloat">writeFloat</h2>

`writeFloat(value:float):void`

<h2 id="ByteArray_writeDouble">writeDouble</h2>

`writeDouble(value:double):void`


<h2 id="ByteArray_readBytes">readBytes</h2>

`readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void`

在 bytes 中 offset 指定的位置开始，写入 length（默认为：bytesAvailable）长度的字节。

`readBytes(length:uint = 0):String`

方法重载：读取 length（默认为：bytesAvailable）指定长度的字节，作为字符串返回。


<h2 id="ByteArray_readBoolean">readBoolean</h2>

`readBoolean():Boolean`

<h2 id="ByteArray_readByte">readByte</h2>

`readByte():byte`

<h2 id="ByteArray_readUByte">readUByte</h2>

`readUByte():ubyte`

<h2 id="ByteArray_readShort">readShort</h2>

`readShort():short`

<h2 id="ByteArray_readUShort">readUShort</h2>

`readUShort():ushort`

<h2 id="ByteArray_readInt">readInt</h2>

`readInt():int`

<h2 id="ByteArray_readUInt">readUInt</h2>

`readUInt():uint`

<h2 id="ByteArray_readLong">readLong</h2>

`readLong():long`

<h2 id="ByteArray_readFloat">readFloat</h2>

`readFloat():float`

<h2 id="ByteArray_readDouble">readDouble</h2>

`readDouble():double`



<h2 id="ByteArray_clear">clear</h2>

`clear():void`

清空 ByteArray

<aside class="notice">

一旦使用完该实例之后，都需要进行清空，这是良好的习惯，并且也有助于提高执行效率。

</aside>


