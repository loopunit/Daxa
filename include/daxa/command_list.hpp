#pragma once

#include <daxa/core.hpp>
#include <daxa/gpu_resources.hpp>
#include <daxa/pipeline.hpp>

namespace daxa
{
    struct CommandListInfo
    {
        std::string debug_name = {};
    };

    struct ImageBlitInfo
    {
        ImageId src_image = {};
        ImageLayout src_image_layout = {};
        ImageId dst_image = {};
        ImageLayout dst_image_layout = {};
        ImageArraySlice src_slice = {};
        std::array<Offset3D, 2> src_offsets = {};
        ImageArraySlice dst_slice = {};
        std::array<Offset3D, 2> dst_offsets = {};
        Filter filter = {};
    };

    struct BufferCopyInfo
    {
        BufferId src_buffer = {};
        usize src_offset = {};
        BufferId dst_buffer = {};
        usize dst_offset = {};
        usize size = {};
    };

    struct BufferImageCopy
    {
        BufferId buffer = {};
        usize buffer_offset = {};
        ImageId image = {};
        ImageLayout image_layout = {};
        ImageArraySlice image_slice = {};
        Offset3D image_offset = {};
        Extent3D image_extent = {};
    };

    struct ImageToBufferInfo
    {
        ImageId image = {};
        ImageLayout image_layout = {};
        ImageArraySlice image_slice = {};
        Offset3D image_offset = {};
        Extent3D image_extent = {};
        BufferId buffer = {};
        usize buffer_offset = {};
    };

    struct ImageCopyInfo
    {
        ImageId src_image = {};
        ImageLayout src_image_layout = {};
        ImageId dst_image = {};
        ImageLayout dst_image_layout = {};
        ImageArraySlice src_slice = {};
        Offset3D src_offset = {};
        ImageArraySlice dst_slice = {};
        Offset3D dst_offset = {};
        Extent3D extent = {};
    };

    struct ImageClearInfo
    {
        ImageLayout dst_image_layout = {};
        ClearValue clear_value;
        ImageId dst_image = {};
        ImageMipArraySlice dst_slice = {};
    };

    struct BufferClearInfo
    {
        BufferId buffer = {};
        usize offset = {};
        usize size = {};
        u32 clear_value = {};
    };

    struct PipelineBarrierInfo
    {
        Access awaited_pipeline_access = AccessConsts::NONE;
        Access waiting_pipeline_access = AccessConsts::NONE;
    };

    struct PipelineBarrierImageTransitionInfo
    {
        Access awaited_pipeline_access = AccessConsts::NONE;
        Access waiting_pipeline_access = AccessConsts::NONE;
        ImageLayout before_layout = ImageLayout::UNDEFINED;
        ImageLayout after_layout = ImageLayout::UNDEFINED;
        ImageId image_id = {};
        ImageMipArraySlice image_slice = {};
    };

    struct RenderAttachmentInfo
    {
        ImageViewId image_view{};
        ImageLayout layout = ImageLayout::ATTACHMENT_OPTIMAL;
        AttachmentLoadOp load_op = AttachmentLoadOp::DONT_CARE;
        AttachmentStoreOp store_op = AttachmentStoreOp::STORE;
        ClearValue clear_value = {};
    };

    struct RenderPassBeginInfo
    {
        std::vector<RenderAttachmentInfo> color_attachments = {};
        std::optional<RenderAttachmentInfo> depth_attachment = {};
        std::optional<RenderAttachmentInfo> stencil_attachment = {};
        Rect2D render_area = {};
    };

    struct DrawInfo
    {
        u32 vertex_count = {};
        u32 instance_count = 1;
        u32 first_vertex = {};
        u32 first_instance = 0;
    };

    struct DrawIndexedInfo
    {
        u32 index_count = {};
        u32 instance_count = 1;
        u32 first_index = {};
        u32 vertex_offset = {};
        u32 first_instance = 0;
    };

    struct DrawIndirectInfo
    {
        BufferId indirect_buffer = {};
        usize offset = {};
        u32 draw_count = {};
        u32 stride = {};
    };

    struct CommandList : ManagedPtr
    {
        CommandList();

        void copy_buffer_to_buffer(BufferCopyInfo const & info);
        void copy_buffer_to_image(BufferImageCopy const & info);
        void copy_image_to_buffer(BufferImageCopy const & info);
        void copy_image_to_image(ImageCopyInfo const & info);
        void blit_image_to_image(ImageBlitInfo const & info);

        void clear_buffer(BufferClearInfo const & info);
        void clear_image(ImageClearInfo const & info);

        void pipeline_barrier(PipelineBarrierInfo const & info);
        void pipeline_barrier_image_transition(PipelineBarrierImageTransitionInfo const & info);

        void push_constant(void const * data, u32 size, u32 offset = 0);
        template <typename T>
        void push_constant(T const & constant, usize offset = 0)
        {
            push_constant(&constant, static_cast<u32>(sizeof(T)), static_cast<u32>(offset));
        }
        void set_pipeline(ComputePipeline const & pipeline);
        void set_pipeline(RasterPipeline const & pipeline);
        void dispatch(u32 group_x, u32 group_y = 1, u32 group_z = 1);

        void destroy_buffer_deferred(BufferId id);
        void destroy_image_deferred(ImageId id);
        void destroy_image_view_deferred(ImageViewId id);
        void destroy_sampler_deferred(SamplerId id);

        void begin_renderpass(RenderPassBeginInfo const & info);
        void end_renderpass();
        void set_viewport(ViewportInfo const & info);
        void set_scissor(Rect2D const & info);
        void set_index_buffer(BufferId id, usize offset, usize index_type_byte_size = sizeof(u32));
        void draw(DrawInfo const & info);
        void draw_indexed(DrawIndexedInfo const & info);
        void draw_indirect(DrawIndirectInfo const & info);

        void complete();
        auto is_complete() const -> bool;

        auto info() const -> CommandListInfo const &;

      private:
        friend struct Device;
        CommandList(ManagedPtr impl);
    };
} // namespace daxa